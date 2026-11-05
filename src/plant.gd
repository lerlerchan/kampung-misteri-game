## One script for all plants; behaviour is picked by `kind` (pisang/kelapa/durian).
extends Node2D

const R := preload("res://src/rules.gd")

var kind: String
var data: Dictionary
var cell: Vector2i
var hp: float
var main: Node
var timer: float = 0.0

const COLORS := {"pisang": Color("#78B84A"), "kelapa": Color("#2F8F72"), "durian": Color("#D8A92E")} # palette: design/ux/hud.md


## Configures the plant. Call before add_child.
func setup(p_kind: String, p_data: Dictionary, p_cell: Vector2i, p_main: Node) -> void:
	kind = p_kind
	data = p_data
	cell = p_cell
	main = p_main
	hp = float(data.hp)
	position = R.cell_center(cell, main.board)
	timer = float(data.get("coin_every", data.get("shot_every", 0.0)))
	var half: float = float(main.board.cell) * 0.35
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	poly.color = COLORS.get(kind, Color.WHITE)
	add_child(poly)
	var l := Label.new()
	l.text = data.name
	l.position = Vector2(-half, -half)
	l.size = Vector2(half * 2, half * 2)
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_color_override("font_color", Color.BLACK)
	l.add_theme_font_size_override("font_size", 12)
	add_child(l)


func _process(delta: float) -> void:
	if main.over:
		return
	match kind:
		"pisang":
			timer -= delta
			if timer <= 0.0:
				timer += float(data.coin_every)
				main.spawn_coin(position + Vector2(0, -main.board.cell * 0.4))
		"kelapa":
			timer = maxf(timer - delta, 0.0)
			if timer <= 0.0 and main.pest_ahead(cell.y, position.x):
				timer = float(data.shot_every)
				main.spawn_coconut(position, cell.y, data)


## Takes bite damage from `biter`; durian thorns hurt the biter back.
func take_bite(amount: float, biter: Node) -> void:
	hp = R.apply_damage(hp, amount)
	if data.has("thorns"):
		biter.take_damage(float(data.thorns))
	if hp <= 0.0:
		main.plants.erase(cell)
		queue_free()
