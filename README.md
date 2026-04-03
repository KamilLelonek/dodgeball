# Dodgeball

Elixir solution for the **Dodgeball** programming challenge: players stand on a 2D grid with integer coordinates, and a ball moves between them until no legal throw remains.

## Problem

- Each player has an index `1 .. N` and a position `(x, y)` with `x`, `y` in [-10^9, 10^9].
- The ball starts with player `S`, having arrived from compass direction `D` (one of `N`, `NE`, `E`, `SE`, `S`, `SW`, `W`, `NW`).
- **Throwing rules**
  - From the direction the ball **just came from**, scan **clockwise** in steps of **45°** (the eight compass directions in order).
  - Throw along the **first** direction in that scan where **at least one** other player lies on the **open ray** (same line through the thrower, in the direction of the compass vector, not behind the thrower).
  - If several players share that direction, the **nearest** one (Euclidean distance) receives the ball.
  - The thrower **leaves the field** and cannot be targeted again.
- The game **ends** when the current holder has **no** valid target in any of the eight directions.
- The **first possession** (ball arriving at `S` from `D`) does **not** count as a throw.

**Answer** for each test case: two integers `number_of_throws` and `last_player_index` (1-based).

**Constraints** (as in the original problem): `2 <= N <= 1000` per case; `T` test cases per file.

### Examples

| Case | N | Start | From | Path (holders) | Output |
|------|---|-------|------|----------------|--------|
| 1 | 8 | 5 | NW | 5 → 6 → 1 → 7 → 8 | `4 8` |
| 2 | 8 | 4 | SE | 4 → 3 → 5 → 2 → 1 → 6 | `5 6` |

Fixture files under `test/fixtures/` encode these two cases in text and JSON.

## Input formats

### Plain text

1. `T` - number of test cases.
2. For each case:
   - `N` - number of players.
   - `N` lines: `x y` per player, in order of index `1 .. N`.
   - `D` - direction string (e.g. `NW`).
   - `S` - starting player index.

### JSON

Array of objects:

- `players`: array of `[x, y]` pairs, index implied by order (first element is player `1`).
- `startingDirection`: string, same as `D`.
- `startingPlayer`: integer, same as `S`.

Either format can be passed as a single string to `Dodgeball.InputParser.parse/1` (JSON is detected when the trimmed string decodes to a JSON array).

## Output (CLI)

One line per test case: `throws last_player`, space-separated (matches the challenge output).

## Elixir API

`Dodgeball.InputParser.parse/1` returns a list of maps `%{players: %{index => {x, y}}, starting_direction: d, starting_player: s}`. Malformed input typically raises (`MatchError`, `FunctionClauseError`, or `ArgumentError` from `String.to_integer/1`, etc.).

```elixir
Dodgeball.play(players_by_index,
  ball_comes_from: "NW",
  starting_at: 5
)
#=> {4, 8}   # throws, last_player
```

## CLI

```bash
mix deps.get
mix escript.build
./dodgeball < input.txt
```

## Tests

```bash
mix test
```

Fixture-driven checks use `test/fixtures/two_cases.txt`, `two_cases.json`, and `two_cases_expected.txt` (loaded via `Dodgeball.Test.Fixtures.read/1`).
