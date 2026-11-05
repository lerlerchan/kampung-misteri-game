## One script for all pests (lipas/biawak/gagak). Gagak hops the first plant it meets (data.hops).
extends Node2D

const R := preload("res://src/rules.gd")

const COLORS := {"lipas": Color("#8C4F32"), "biawak": Color("#526B4B"), "gagak": Color("#343A46")} # palette: design/ux/hud.md

var kind: String
var data: Dictionary
var lane: int
var hp: float
var hops: int
var hopping: bool = false
var bite_t: float = 0.0
var half: float
var main: Node


## Configures the pest at the right edge of `p_lane`. Call before add_child.
func setup(p_kind: String, p_data: Dictionary, p_lane: int, p_main: Node) -> void:
	kind = p_kind
	data = p_data
	lane = p_lane
	main = p_main
	hp = float(data.hp)
	hops = int(data.get("hops", 0))
	half = float(main.board.cell) * 0.25
	position = Vector2(main.board.origin_x + main.board.cols * main.board.cell + half, main.lane_y(lane))
	add_to_group("pests")
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-half, -half), Vector2(half, -half), Vector2(half, half), Vector2(-half, half)])
	poly.color = COLORS.get(kind, Color.WHITE)
	add_child(poly)
	var l := Label.new()
	l.text = data.name
	l.position = Vector2(-half, -half * 2.2)
	add_child(l)


func _process(delta: float) -> void:
	if main.over or hopping:
		return
	var front := position.x - half
	if front < main.board.origin_x:
		main.lose()
		return
	var plant: Node = main.plant_at(R.cell_at(Vector2(front, position.y), main.board))
	if plant == null:
		position.x -= float(data.speed) * delta
	elif hops > 0:
		_hop(plant)
	else:
		bite_t += delta
		if bite_t >= 1.0: # bite is damage per second
			bite_t -= 1.0
			plant.take_bite(float(data.bite), self)


func _hop(plant: Node) -> void:
	hops -= 1
	hopping = true
	var tx: float = plant.position.x - float(main.board.cell) * 0.5 - half * 0.25
	var y0 := position.y
	var t := create_tween().set_parallel()
	t.tween_property(self, "position:x", tx, float(main.bal.fx.hop_time))
	t.tween_property(self, "position:y", y0 - half * 2.0, float(main.bal.fx.hop_time) * 0.5)
	t.chain().tween_property(self, "position:y", y0, float(main.bal.fx.hop_time) * 0.5)
	t.chain().tween_callback(func() -> void: hopping = false)


## Applies damage; at 0 HP the pest runs off right, fades, and is freed.
func take_damage(amount: float) -> void:
	if hp <= 0.0:
		return
	hp = R.apply_damage(hp, amount)
	if hp > 0.0:
		return
	remove_from_group("pests")
	set_process(false)
	var t := create_tween().set_parallel()
	t.tween_property(self, "position:x", position.x + 600.0, float(main.bal.fx.fade_time))
	t.tween_property(self, "modulate:a", 0.0, float(main.bal.fx.fade_time))
	t.chain().tween_callback(queue_free)
