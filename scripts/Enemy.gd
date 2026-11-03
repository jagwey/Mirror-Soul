class_name Enemy
extends CharacterBody2D

signal died
@export_enum("Skeleton Turret", "The Overseer") var enemy_type := 0
@export var max_health := 100.0
@export var fire_interval := 2.0
@export var projectile_speed := 320.0
@export var projectile_damage := 10.0
@export var use_laser := false
@export var laser_duration := 0.45
var health := 100.0
var _timer := 0.0
var _player: Node2D
var _pool: ProjectilePool

func _ready() -> void:
	add_to_group("Enemy")
	health = max_health
	_player = get_tree().get_first_node_in_group("Player") as Node2D
	_pool = get_tree().get_first_node_in_group("ProjectilePool") as ProjectilePool
	if get_node_or_null("CollisionShape2D") == null:
		var shape_node := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 20.0
		shape_node.shape = shape
		add_child(shape_node)
	queue_redraw()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		return
	_timer -= delta
	if _timer <= 0.0:
		_timer = fire_interval
		_fire()

func _fire() -> void:
	var direction := global_position.direction_to(_player.global_position)
	if direction == Vector2.ZERO:
		return
	var count := 5 if enemy_type == 1 else 1
	for i in count:
		var shot_dir := direction.rotated(deg_to_rad((i - (count - 1) / 2.0) * 15.0))
		if use_laser:
			var beam := preload("res://scripts/LaserBeam.gd").new()
			beam.damage_per_sec = projectile_damage
			beam.duration = laser_duration
			get_tree().current_scene.add_child(beam)
			beam.global_position = global_position + shot_dir * 23.0
			beam.global_rotation = shot_dir.angle()
		elif is_instance_valid(_pool):
			_pool.spawn_shot(global_position + shot_dir * 23.0, shot_dir, projectile_speed, projectile_damage)

func take_damage(amount: float, combo_count := 0) -> void:
	health -= amount
	if combo_count >= 2:
		_show_combo(combo_count)
	if health <= 0.0:
		died.emit()
		queue_free()

func _show_combo(count: int) -> void:
	# Aynı sürekli ışın her karede yeni etiket üretmesin.
	if has_node("ComboLabel"):
		return
	var label := Label.new()
	label.name = "ComboLabel"
	label.text = "x%d COMBO!" % count
	label.position = Vector2(-35, -50)
	add_child(label)
	var tween := create_tween()
	tween.tween_property(label, "position:y", -80.0, 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 20.0, Color(1.0, 0.12, 0.12) if enemy_type == 0 else Color(0.8, 0.15, 1.0))
