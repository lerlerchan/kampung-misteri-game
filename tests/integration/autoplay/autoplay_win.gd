## Integration check: 3 kelapa per lane (+ durian wall) must clear all 5 waves.
## Run: godot --headless --path . -s res://tests/integration/autoplay/autoplay_win.gd
extends SceneTree

const Plant := preload("res://src/plant.gd")
const TIME_SCALE := 8.0 # sim speed-up only, not a gameplay value
const TIMEOUT_FRAMES := 20000

var main: Node
var frames := 0


func _initialize() -> void:
	Engine.time_scale = TIME_SCALE
	main = (load("res://src/main.tscn") as PackedScene).instantiate()
	root.add_child(main)


func _place(kind: String, cell: Vector2i) -> void:
	var p := Plant.new()
	p.setup(kind, main.bal.plants[kind], cell, main)
	main.add_child(p)
	main.plants[cell] = p


func _process(_delta: float) -> bool:
	frames += 1
	if frames == 1: # main._ready has run by the first frame
		for lane in int(main.board.lanes):
			for col in 3:
				_place("kelapa", Vector2i(col, lane))
			_place("durian", Vector2i(4, lane))
	if main.over:
		var won: bool = get_nodes_in_group("pests").is_empty() and main.wave_idx == main.bal.waves.list.size()
		print("autoplay_win: ", "WON" if won else "LOST", " after ", frames, " frames")
		if DisplayServer.get_name() != "headless": # windowed run doubles as screenshot capture
			await process_frame
			root.get_texture().get_image().save_png("res://production/qa/evidence/2026-11-05-kampung-win.png")
		quit(0 if won else 1)
	elif frames > TIMEOUT_FRAMES:
		print("autoplay_win: TIMEOUT")
		quit(2)
	return false
