## Kampung Misteri main scene: board, sen economy, wave spawner, win/lose.
## Implements the "Game design" section of the kampung-misteri plan; numbers from balance.json.
extends Node2D

const R := preload("res://src/rules.gd")

const Plant := preload("res://src/plant.gd")
const Pest := preload("res://src/pest.gd")
const Coconut := preload("res://src/coconut.gd")
const HUD_PATH := "res://src/hud.tscn"

var bal: Dictionary
var board: Dictionary
var sen: int = 0
var selected: String = ""
var plants: Dictionary = {} # Vector2i -> Plant
var over: bool = false
var wave_idx: int = 0
var wave_t: float = 0.0
var spawn_t: float = 0.0
var sky_t: float = 0.0
var queue: Array = []
var hud: Node = null
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	bal = R.load_balance()
	board = bal.board
	sen = int(bal.economy.start_sen)
	wave_t = float(bal.waves.first_delay)
	sky_t = float(bal.economy.sky_coin_every)
	_build_board()
	if ResourceLoader.exists(HUD_PATH):
		hud = (load(HUD_PATH) as PackedScene).instantiate()
		add_child(hud)
		hud.card_picked.connect(func(k: String) -> void: selected = k)
		hud.set_wave(0, bal.waves.list.size())
	_sync_hud()


func _build_board() -> void:
	var cell: float = board.cell
	var house := ColorRect.new()
	house.color = Color("#8A5638")
	house.position = Vector2(0, board.origin_y)
	house.size = Vector2(board.origin_x, cell * board.lanes)
	add_child(house)
	var hl := Label.new()
	hl.text = "Rumah Kampung"
	hl.position = house.position + Vector2(8, 8)
	add_child(hl)
	for c in int(board.cols):
		for l in int(board.lanes):
			var r := ColorRect.new()
			r.color = Color("#4E9A52") if (c + l) % 2 == 0 else Color("#5AA85E")
			r.position = Vector2(board.origin_x + c * cell, board.origin_y + l * cell)
			r.size = Vector2(cell, cell)
			r.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(r)


## Screen y of a lane's centre.
func lane_y(lane: int) -> float:
	return R.cell_center(Vector2i(0, lane), board).y


## Plant at a grid cell, or null.
func plant_at(cell: Vector2i) -> Node:
	return plants.get(cell)


## True when a living pest in `lane` is right of screen x `x`.
func pest_ahead(lane: int, x: float) -> bool:
	for p in get_tree().get_nodes_in_group("pests"):
		if p.lane == lane and p.position.x > x:
			return true
	return false


## Adds sen and refreshes the HUD.
func add_sen(n: int) -> void:
	sen += n
	_sync_hud()


## Spawns a clickable coin at pos worth economy.coin_value.
func spawn_coin(pos: Vector2) -> void:
	var b := Button.new()
	b.text = str(int(bal.economy.coin_value))
	b.size = Vector2(48, 48)
	b.position = pos - b.size / 2
	var gold := StyleBoxFlat.new()
	gold.bg_color = Color("#F4C542")
	gold.set_corner_radius_all(24)
	for s in ["normal", "hover", "pressed"]:
		b.add_theme_stylebox_override(s, gold)
	b.add_theme_color_override("font_color", Color("#3A2A1A"))
	b.add_theme_color_override("font_hover_color", Color("#3A2A1A"))
	b.pressed.connect(func() -> void:
		add_sen(int(bal.economy.coin_value))
		b.queue_free())
	add_child(b)


## Spawns a coconut projectile for a kelapa plant.
func spawn_coconut(pos: Vector2, lane: int, data: Dictionary) -> void:
	var c := Coconut.new()
	c.setup(pos, lane, data, self)
	add_child(c)


## A pest reached the house.
func lose() -> void:
	_end(false)


func _end(won: bool) -> void:
	if over:
		return
	over = true
	if hud:
		hud.show_result(won)
	else:
		var l := Label.new()
		l.text = "MENANG!" if won else "KALAH!"
		l.add_theme_font_size_override("font_size", 64)
		l.position = Vector2(500, 300)
		add_child(l)


func _sync_hud() -> void:
	if hud == null:
		return
	hud.set_sen(sen)
	for k in bal.plants.keys():
		hud.set_card_enabled(k, R.can_afford(sen, bal.plants[k]))


func _process(delta: float) -> void:
	if over:
		return
	sky_t -= delta
	if sky_t <= 0.0:
		sky_t += float(bal.economy.sky_coin_every)
		var p := Vector2(rng.randf_range(board.origin_x + 24, board.origin_x + board.cols * board.cell - 24), board.origin_y)
		spawn_coin(p)
		var coin: Node = get_child(get_child_count() - 1)
		create_tween().tween_property(coin, "position:y", lane_y(rng.randi_range(0, int(board.lanes) - 1)), float(bal.fx.coin_fall))
	if queue.size() > 0:
		spawn_t -= delta
		if spawn_t <= 0.0:
			spawn_t = float(bal.waves.spawn_every)
			var s: Array = queue.pop_front()
			var pest := Pest.new()
			pest.setup(s[0], bal.pests[s[0]], s[1], self)
			add_child(pest)
	elif wave_idx < bal.waves.list.size():
		wave_t -= delta
		if wave_t <= 0.0:
			queue = R.wave_spawns(bal.waves.list[wave_idx], int(board.lanes), int(bal.waves.seed) + wave_idx)
			wave_idx += 1
			spawn_t = 0.0
			wave_t = float(bal.waves.gap)
			if hud:
				hud.set_wave(wave_idx, bal.waves.list.size())
	elif get_tree().get_nodes_in_group("pests").is_empty():
		_end(true)


func _unhandled_input(event: InputEvent) -> void:
	if over:
		return
	if event is InputEventKey and event.pressed:
		# Debug/fallback card select: keys 1..n.
		var i: int = event.keycode - KEY_1
		var kinds: Array = bal.plants.keys()
		if i >= 0 and i < kinds.size():
			selected = kinds[i]
			if hud:
				hud.select_card(selected)
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := R.cell_at(get_global_mouse_position(), board)
		if cell.x < 0 or selected == "" or plants.has(cell):
			return
		var data: Dictionary = bal.plants[selected]
		if not R.can_afford(sen, data):
			return
		var pl := Plant.new()
		pl.setup(selected, data, cell, self)
		add_child(pl)
		plants[cell] = pl
		add_sen(-int(data.cost))
