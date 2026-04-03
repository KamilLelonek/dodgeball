defmodule DodgeballTest do
  use ExUnit.Case, async: true

  # Players positioned at the corners and edges of a 20x20 grid,
  # matching the example from the problem statement.
  @grid_players %{
    1 => {-10, -10},
    2 => {-10, 10},
    3 => {0, -10},
    4 => {0, 10},
    5 => {10, -10},
    6 => {10, 10},
    7 => {-9, -10},
    8 => {-9, 0}
  }

  @large_grid_players %{
    1 => {-1_000_000, -1_000_000},
    2 => {-1_000_000, 1_000_000},
    3 => {0, -1_000_000},
    4 => {0, 1_000_000},
    5 => {1_000_000, -1_000_000},
    6 => {1_000_000, 1_000_000},
    7 => {-999_999, -1_000_000},
    8 => {-999_999, 0}
  }

  describe "play/2" do
    test "example 1: starting from player 5, direction NW -> 4 throws, last player 8" do
      assert Dodgeball.play(@grid_players, ball_comes_from: "NW", starting_at: 5) == {4, 8}
    end

    test "example 2: starting from player 4, direction SE -> 5 throws, last player 6" do
      assert Dodgeball.play(@large_grid_players, ball_comes_from: "SE", starting_at: 4) ==
               {5, 6}
    end

    test "game ends immediately when no player is reachable from any direction" do
      isolated_players = %{1 => {0, 0}, 2 => {1, 2}}
      # Player 2 is at {1,2} - not on any of the 8 exact compass directions from {0,0}

      assert Dodgeball.play(isolated_players, ball_comes_from: "N", starting_at: 1) == {0, 1}
    end

    test "nearest player wins when multiple players share the same direction" do
      players = %{
        1 => {0, 0},
        2 => {0, 5},
        3 => {0, 10}
      }

      # From player 1 scanning clockwise from N+1 = NE, first candidate is N.
      # Both player 2 and 3 are due North; player 2 is closer.
      {_throws, last} = Dodgeball.play(players, ball_comes_from: "N", starting_at: 1)
      # Player 1 throws to 2 (nearest North), then 2 has only 3 left (also North).
      # 2 throws to 3. 3 has nobody. So 2 throws, last player 3.

      assert last == 3
    end

    test "diagonal direction is detected correctly" do
      players = %{
        1 => {0, 0},
        2 => {3, 3},
        3 => {6, 6}
      }

      # Player 2 and 3 are exactly NE of player 1.
      # Starting direction S means scan starts from SW, W, NW, N, NE (first hit).
      {throw_count, last_player} =
        Dodgeball.play(players, ball_comes_from: "S", starting_at: 1)

      assert throw_count == 2
      assert last_player == 3
    end
  end
end

defmodule Dodgeball.FixturesTest do
  use ExUnit.Case, async: true

  @expected_first_case %{
    players: %{
      1 => {-10, -10},
      2 => {-10, 10},
      3 => {0, -10},
      4 => {0, 10},
      5 => {10, -10},
      6 => {10, 10},
      7 => {-9, -10},
      8 => {-9, 0}
    },
    starting_direction: "NW",
    starting_player: 5
  }

  defp parse_cases_from_fixture(filename) do
    filename
    |> Dodgeball.Test.Fixtures.read()
    |> String.trim()
    |> Dodgeball.InputParser.parse()
  end

  defp expected_output_lines(filename) do
    filename
    |> Dodgeball.Test.Fixtures.read()
    |> String.split("\n", trim: true)
  end

  defp simulation_output_line(%{
         players: players,
         starting_direction: direction,
         starting_player: starter
       }) do
    players
    |> Dodgeball.play(ball_comes_from: direction, starting_at: starter)
    |> then(fn {throws, last_player} -> "#{throws} #{last_player}" end)
  end

  describe "fixtures/two_cases" do
    test "parse/1 text: two cases, first matches canonical example" do
      parsed = parse_cases_from_fixture("two_cases.txt")

      assert length(parsed) == 2

      [first | _] = parsed

      assert first == @expected_first_case
    end

    test "parse/1 JSON: two cases, first matches canonical example" do
      parsed = parse_cases_from_fixture("two_cases.json")

      assert length(parsed) == 2

      [first | _] = parsed

      assert first == @expected_first_case
    end

    test "parse/1 text and JSON produce the same cases" do
      assert parse_cases_from_fixture("two_cases.txt") ==
               parse_cases_from_fixture("two_cases.json")
    end

    test "simulation output matches two_cases_expected.txt" do
      cases = parse_cases_from_fixture("two_cases.txt")
      expected_lines = expected_output_lines("two_cases_expected.txt")

      assert length(cases) == length(expected_lines)

      for {test_case, expected_line} <- Enum.zip(cases, expected_lines) do
        assert simulation_output_line(test_case) == expected_line
      end
    end
  end
end
