## Coconut projectile: flies right along a lane, damages the first pest it touches.
extends Node2D

const R := preload("res://src/rules.gd")

var lane: int
var damage: float
var speed: float
var main: Node


## Configures the projectile from kelapa data. Call before add_child.
func setup(pos: Vector2, p_lane: int, data: Dictionary, p_main: Node) -> void:
	position = pos
	lane = p_lane
	damage = float(data.shot_damage)
	speed = float(data.shot_speed)
	main = p_main
	var r := float(main.board.cell) * 0.12
	var poly := Polygon2D.new()
	poly.polygon = PackedVector2Array([Vector2(-r, -r), Vector2(r, -r), Vector2(r, r), Vector2(-r, r)])
	poly.color = Color("#8A5638")
	add_child(poly)


func _process(delta: float) -> void:
	position.x += speed * delta
	var reach := float(main.board.cell) * 0.3
	for p in get_tree().get_nodes_in_group("pests"):
		if p.lane == lane and absf(p.position.x - position.x) < reach:
			p.take_damage(damage)
			queue_free()
			return
	if position.x > get_viewport_rect().size.x + 50.0:
		queue_free()
