defmodule Dodgeball do
  @moduledoc """
  Simulates the Dodgeball grid problem: clockwise compass scan from the incoming
  direction, first ray that contains an opponent, nearest player on that ray;
  thrower is removed after each throw.

  Returns `{throw_count, last_player_index}`. The initial arrival at the starter
  does not count as a throw. See the README for rules, limits, and examples.
  """

  @compass_directions ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]

  @direction_vectors %{
    "N" => {0, 1},
    "NE" => {1, 1},
    "E" => {1, 0},
    "SE" => {1, -1},
    "S" => {0, -1},
    "SW" => {-1, -1},
    "W" => {-1, 0},
    "NW" => {-1, 1}
  }

  @direction_index @compass_directions |> Enum.with_index() |> Map.new()

  @type coordinate :: {integer(), integer()}
  @type player_index :: pos_integer()
  @type players :: %{player_index() => coordinate()}
  @type direction :: String.t()
  @type result :: {throw_count :: non_neg_integer(), last_player :: player_index()}

  @spec play(players(), ball_comes_from: direction(), starting_at: player_index()) :: result()
  def play(players, ball_comes_from: direction, starting_at: starting_player),
    do: do_play(players, direction, starting_player, 0)

  defp do_play(players, received_from_direction, current_player, throw_count) do
    thrower_position = players[current_player]
    opponents = Map.delete(players, current_player)

    throw_target =
      first_target_along_clockwise_scan(opponents, thrower_position, received_from_direction)

    apply_throw_outcome(throw_target, opponents, current_player, throw_count)
  end

  defp apply_throw_outcome(nil, _opponents, current_player, throw_count),
    do: {throw_count, current_player}

  defp apply_throw_outcome(
         {throw_direction, {next_player, _target_position}},
         opponents,
         _current_player,
         throw_count
       ) do
    do_play(
      opponents,
      opposite_direction(throw_direction),
      next_player,
      throw_count + 1
    )
  end

  defp first_target_along_clockwise_scan(
         opponents,
         thrower_position,
         received_from_direction
       ) do
    received_from_direction
    |> clockwise_scan_order()
    |> Enum.find_value(&first_hit_along_direction(&1, opponents, thrower_position))
  end

  defp first_hit_along_direction(scan_direction, opponents, thrower_position) do
    direction_vector = @direction_vectors[scan_direction]

    candidates_on_ray =
      opponents
      |> opponents_on_compass_ray(thrower_position, direction_vector)

    thrower_position
    |> nearest_player_entry(candidates_on_ray)
    |> pair_with_scan_direction(scan_direction)
  end

  defp pair_with_scan_direction(nil, _scan_direction), do: nil

  defp pair_with_scan_direction(nearest_entry, scan_direction),
    do: {scan_direction, nearest_entry}

  defp opponents_on_compass_ray(opponents, origin, direction_vector) do
    Enum.filter(opponents, fn {_player_index, grid_position} ->
      exactly_in_direction?(origin, grid_position, direction_vector)
    end)
  end

  defp nearest_player_entry(_origin, []), do: nil

  defp nearest_player_entry(origin, candidate_entries) do
    Enum.min_by(candidate_entries, fn {_player_index, grid_position} ->
      squared_distance(origin, grid_position)
    end)
  end

  defp clockwise_scan_order(received_from_direction) do
    # Scan starts one step clockwise from where the ball came from.
    start_index = @direction_index[received_from_direction] + 1
    Enum.map(0..7, &compass_direction_at_offset(start_index, &1))
  end

  defp compass_direction_at_offset(start_index, offset),
    do: Enum.at(@compass_directions, rem(start_index + offset, 8))

  defp opposite_direction(direction),
    do: compass_direction_at_offset(@direction_index[direction], 4)

  defp exactly_in_direction?(from_coordinate, to_coordinate, direction_vector) do
    displacement(from_coordinate, to_coordinate)
    |> lies_on_directed_ray?(direction_vector)
  end

  defp lies_on_directed_ray?({vector_x, vector_y}, {0, dy}),
    do: vector_x == 0 and vector_y * dy > 0

  defp lies_on_directed_ray?({vector_x, vector_y}, {dx, 0}),
    do: vector_y == 0 and vector_x * dx > 0

  defp lies_on_directed_ray?({vector_x, vector_y}, {dx, dy}),
    do: vector_x * dy == vector_y * dx and vector_x * dx > 0

  defp displacement({from_x, from_y}, {to_x, to_y}),
    do: {to_x - from_x, to_y - from_y}

  defp squared_distance({from_x, from_y}, {to_x, to_y}),
    do: (to_x - from_x) ** 2 + (to_y - from_y) ** 2
end
