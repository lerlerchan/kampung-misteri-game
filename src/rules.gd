## Pure game rules for Kampung Misteri. No nodes, no scene state: unit-testable.
## Numbers come from res://assets/data/balance.json (see design/game-brief.md).
class_name Rules
extends RefCounted

const BALANCE_PATH := "res://assets/data/balance.json"


## Loads and parses balance.json. Returns an empty Dictionary on failure.
static func load_balance(path: String = BALANCE_PATH) -> Dictionary:
	var text := FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	if data is Dictionary:
		return data
	push_error("Rules: cannot parse %s" % path)
	return {}


## True when the player has enough sen for the plant kind.
static func can_afford(sen: int, plant: Dictionary) -> bool:
	return sen >= int(plant.cost)


## HP left after taking damage, never below 0.
static func apply_damage(hp: float, amount: float) -> float:
	return maxf(hp - amount, 0.0)


## Expands one wave entry ({"lipas": 3, ...}) into a shuffled spawn order of
## [kind, lane] pairs. Same seed gives same order.
static func wave_spawns(wave: Dictionary, lanes: int, seed_value: int) -> Array:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var kinds: Array = []
	for kind in wave.keys():
		for i in int(wave[kind]):
			kinds.append(kind)
	# Fisher-Yates with our own rng so the order is deterministic.
	for i in range(kinds.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var t = kinds[i]
		kinds[i] = kinds[j]
		kinds[j] = t
	var out: Array = []
	for kind in kinds:
		out.append([kind, rng.randi_range(0, lanes - 1)])
	return out


## Grid cell [col, lane] under a screen point, or [-1, -1] when off the board.
static func cell_at(pos: Vector2, board: Dictionary) -> Vector2i:
	var c := int(floor((pos.x - board.origin_x) / board.cell))
	var l := int(floor((pos.y - board.origin_y) / board.cell))
	if c < 0 or c >= int(board.cols) or l < 0 or l >= int(board.lanes):
		return Vector2i(-1, -1)
	return Vector2i(c, l)


## Screen centre of a grid cell.
static func cell_center(cell: Vector2i, board: Dictionary) -> Vector2:
	return Vector2(board.origin_x + (cell.x + 0.5) * board.cell, board.origin_y + (cell.y + 0.5) * board.cell)
