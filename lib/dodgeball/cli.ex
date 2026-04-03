defmodule Dodgeball.CLI do
  @moduledoc """
  Reads stdin as UTF-8 text, parses cases with `InputParser`, prints one line per
  case: `throws last_player` (challenge output format).
  """

  def main(_args \\ []) do
    :stdio
    |> IO.read(:all)
    |> String.trim()
    |> Dodgeball.InputParser.parse()
    |> Enum.each(&puts_case_line/1)
  end

  defp puts_case_line(%{
         players: players_by_index,
         starting_direction: received_from_direction,
         starting_player: starting_player_id
       }) do
    {throw_count, last_player} =
      Dodgeball.play(players_by_index,
        ball_comes_from: received_from_direction,
        starting_at: starting_player_id
      )

    "#{throw_count} #{last_player}"
    |> IO.puts()
  end
end
