defmodule Dodgeball.InputParser do
  @moduledoc """
  Parses challenge input as **JSON** (array of case objects) or **plain text**
  (block format with `T`, then per case `N`, coordinates, direction, start index).

  See the README for exact field names and layout.
  """

  @type test_case :: %{
          players: Dodgeball.players(),
          starting_direction: Dodgeball.direction(),
          starting_player: Dodgeball.player_index()
        }

  @spec parse(String.t()) :: [test_case()]
  def parse(raw_input) do
    raw_input
    |> String.trim()
    |> then(fn trimmed -> parse_decoded(trimmed, Jason.decode(trimmed)) end)
  end

  defp parse_decoded(_trimmed, {:ok, decoded}) when is_list(decoded),
    do: Enum.map(decoded, &build_case_from_json_object/1)

  defp parse_decoded(trimmed, _decode_result), do: parse_text(trimmed)

  defp build_case_from_json_object(%{
         "players" => coordinate_pairs,
         "startingDirection" => starting_direction,
         "startingPlayer" => starting_player_id
       }) do
    test_case_from_coordinates(coordinate_pairs, starting_direction, starting_player_id)
  end

  defp parse_text(raw_input) do
    [_suite_case_count | case_lines] =
      raw_input
      |> String.split("\n", trim: true)

    parse_text_cases(case_lines, [])
  end

  defp parse_text_cases([], parsed_cases), do: Enum.reverse(parsed_cases)

  defp parse_text_cases([player_count_line | following_lines], parsed_cases) do
    player_count = String.to_integer(player_count_line)

    {test_case, remaining_lines} =
      build_test_case_from_text_lines(following_lines, player_count)

    parse_text_cases(remaining_lines, [test_case | parsed_cases])
  end

  defp build_test_case_from_text_lines(lines, player_count) do
    {coordinate_lines, [incoming_direction, starting_player_line | remaining_lines]} =
      Enum.split(lines, player_count)

    coordinate_pairs =
      coordinate_lines
      |> Enum.map(&parse_coordinate_line/1)

    starting_player_id = String.to_integer(starting_player_line)

    test_case =
      test_case_from_coordinates(coordinate_pairs, incoming_direction, starting_player_id)

    {test_case, remaining_lines}
  end

  defp test_case_from_coordinates(coordinate_pairs, starting_direction, starting_player_id) do
    %{
      players: build_players_map(coordinate_pairs),
      starting_direction: starting_direction,
      starting_player: starting_player_id
    }
  end

  defp parse_coordinate_line(line) do
    line
    |> String.split()
    |> Enum.map(&String.to_integer/1)
  end

  defp build_players_map(coordinate_pairs) do
    coordinate_pairs
    |> Enum.with_index(1)
    |> Map.new(fn {[x, y], player_index} -> {player_index, {x, y}} end)
  end
end
