## Self-check for src/rules.gd. Run: godot --headless --path . -s res://tests/unit/rules/test_rules.gd
extends SceneTree

const Rules := preload("res://src/rules.gd")


func _init() -> void:
	var b := Rules.load_balance()
	assert(b.has("plants") and b.has("pests") and b.waves.list.size() == 5, "balance.json loads")

	assert(Rules.can_afford(100, b.plants.kelapa), "exact cost is affordable")
	assert(not Rules.can_afford(99, b.plants.kelapa), "one short is not affordable")

	assert(Rules.apply_damage(10.0, 25.0) == 0.0, "hp floors at 0")
	assert(Rules.apply_damage(100.0, 20.0) == 80.0, "damage subtracts")

	var wave := {"lipas": 3, "gagak": 2}
	var a := Rules.wave_spawns(wave, 5, 7)
	assert(a.size() == 5, "wave expands to 5 spawns")
	assert(a == Rules.wave_spawns(wave, 5, 7), "same seed same order")
	for s in a:
		assert(s[1] >= 0 and s[1] < 5, "lane in range")

	var board: Dictionary = b.board
	var cell := Vector2i(3, 2)
	assert(Rules.cell_at(Rules.cell_center(cell, board), board) == cell, "cell round trip")
	assert(Rules.cell_at(Vector2(0, 0), board) == Vector2i(-1, -1), "off board")

	print("test_rules: all passed")
	quit(0)
