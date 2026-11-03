class_name Shield
extends Area2D

signal parried
signal blocked
signal upgrade_picked(upgrade_id: String)
const PURE_COLOR := Color(2.0, 2.0, 2.0)
@export var perfect_window := 0.15
@export var parry_multiplier := 3.0
@onready var _collision: CollisionPolygon2D = $CollisionPolygon2D
var active := false
var prism_count := 1
var focus_enabled := false
var auto_aim_enabled := false
var ghost_enabled := false
var is_ghost := false
var stored_damage := 0.0
var _raised_ms := 0
var _touched_lasers: Array[Node] = []

func _ready() -> void:
	collision_mask = 3
	area_entered.connect(_on_area_entered)

func apply_upgrade(upgrade: MirrorUpgrade) -> void:
	var upgrade_id := ""
	match upgrade.kind:
		MirrorUpgrade.Kind.PRISM:
			prism_count = 5 if upgrade.prism_count == 5 else 3
			upgrade_id = "prism"
		MirrorUpgrade.Kind.FOCUS:
			focus_enabled = true
			upgrade_id = "focus"
		MirrorUpgrade.Kind.AUTO_AIM:
			auto_aim_enabled = true
			upgrade_id = "auto_aim"
		MirrorUpgrade.Kind.GHOST:
			ghost_enabled = true
			upgrade_id = "ghost"
	if not upgrade_id.is_empty():
		upgrade_picked.emit(upgrade_id)

func raise() -> void:
	active = true
	_raised_ms = Time.get_ticks_msec()
	_touched_lasers.clear()
	visible = true
	if not is_ghost:
		modulate.a = 1.0
	_collision.set_deferred("disabled", false)

## Yalnızca parmak bırakılması odaklanmış yükü ateşler.
func lower(fire_focus := false) -> void:
	if active and fire_focus and focus_enabled and stored_damage > 0.0:
		_fire_focus()
	stored_damage = 0.0
	active = false
	visible = true
	modulate.a = 0.28
	_collision.set_deferred("disabled", true)

func is_perfect_window() -> bool:
	return active and Time.get_ticks_msec() - _raised_ms <= perfect_window * 1000.0

func aimed_direction(direction: Vector2, origin_pos: Vector2) -> Vector2:
	if not auto_aim_enabled:
		return direction.normalized()
	var nearest: Node2D
	var closest := INF
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy is Node2D:
			var distance: float = origin_pos.distance_squared_to(enemy.global_position)
			if distance < closest and distance > 0.01:
				closest = distance
				nearest = enemy
	if nearest == null:
		return direction.normalized()
	var desired := origin_pos.direction_to(nearest.global_position)
	return direction.normalized().rotated(direction.angle_to(desired) * 0.35)

## Reflect from the aimed shield plane, not a sloped polygon edge.
func reflection_normal() -> Vector2:
	return global_transform.x.normalized()

func reflection_directions(direction: Vector2, origin_pos: Vector2) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var center := aimed_direction(direction, origin_pos)
	for i in prism_count:
		result.append(center.rotated(deg_to_rad((i - (prism_count - 1) / 2.0) * 15.0)))
	return result

func _on_area_entered(area: Area2D) -> void:
	if not active or not area.is_in_group("EnemyProjectile") or not ("velocity" in area):
		return
	var normal := reflection_normal()
	var v: Vector2 = area.velocity
	if v.dot(normal) >= 0.0:
		return
	if focus_enabled and not is_ghost:
		if "damage" in area:
			stored_damage += area.damage
		if area.has_method("deactivate") and "pool" in area and is_instance_valid(area.pool):
			area.pool.recycle(area)
		else:
			area.queue_free()
		blocked.emit()
		return
	v = v.bounce(normal)
	if is_perfect_window() and not is_ghost:
		v *= parry_multiplier
		if "damage" in area:
			area.damage *= parry_multiplier
		area.modulate = PURE_COLOR
		parried.emit()
	elif not is_ghost:
		blocked.emit()
	var dirs := reflection_directions(v, global_position)
	area.velocity = dirs[0] * v.length()
	if "reflected" in area:
		area.reflected = true
	area.remove_from_group("EnemyProjectile")
	if area.has_method("queue_redraw"):
		area.queue_redraw()
	var pool := get_tree().get_first_node_in_group("ProjectilePool") as ProjectilePool
	if pool and "damage" in area:
		for i in range(1, dirs.size()):
			pool.spawn_shot(area.global_position + dirs[i] * 8.0, dirs[i], v.length(), area.damage, true)

## Sürekli ışın birikimi saniye başına hasara göre hesaplanır.
func laser_contact(laser: Node, delta := 0.0) -> bool:
	if focus_enabled and not is_ghost:
		if "damage_per_sec" in laser:
			stored_damage += laser.damage_per_sec * delta
		if laser not in _touched_lasers:
			_touched_lasers.append(laser)
			blocked.emit()
		return false
	if laser in _touched_lasers:
		return laser.purified
	_touched_lasers.append(laser)
	if is_ghost:
		return false
	if is_perfect_window():
		parried.emit()
		laser.purified = true
		return true
	blocked.emit()
	return false

func absorbs_laser() -> bool:
	return active and focus_enabled and not is_ghost

func _fire_focus() -> void:
	var beam := preload("res://scripts/LaserBeam.gd").new()
	beam.width = 20.0
	beam.duration = 0.18
	beam.burst_damage = stored_damage
	beam.friendly = true
	get_tree().current_scene.add_child(beam)
	beam.global_position = global_position + global_transform.x.normalized() * 10.0
	beam.global_rotation = global_rotation

func leave_ghost() -> void:
	if not ghost_enabled or is_ghost:
		return
	var ghost := duplicate() as Shield
	get_tree().current_scene.add_child(ghost)
	ghost.global_transform = global_transform
	ghost.is_ghost = true
	ghost.focus_enabled = false
	ghost.modulate.a = 0.35
	ghost.raise()
	get_tree().create_timer(3.0).timeout.connect(ghost.queue_free)
