class_name Enemy
extends CharacterBody2D

signal died
@export_enum("Skeleton Turret", "The Overseer") var enemy_type := 0
@export var max_health := 100.0
@export var fire_interval := 2.0
@export var projectile_speed := 320.0
@export var projectile_damage := 10.0
@export var use_laser := true
@export var laser_duration := 1.35
@export var warning_duration := 0.9
@export var initial_delay := -1.0
var _warning: Line2D
var _aim := Vector2.RIGHT
var _charging := false
var health := 100.0
var _timer := 0.0
var _player: Node2D
var _pool: ProjectilePool
var _next_damage_label_ms := 0
var _dying := false

func _ready() -> void:
	add_to_group("Enemy")
	health = max_health
	_timer = initial_delay if initial_delay >= 0.0 else fire_interval + randf_range(0.0, 0.8)
	_warning = Line2D.new()
	_warning.width = 1.5
	_warning.default_color = Color(1.0, 0.25, 0.3, 0.35)
	_warning.hide()
	add_child(_warning)
	_player = get_tree().get_first_node_in_group("Player") as Node2D
	_pool = get_tree().get_first_node_in_group("ProjectilePool") as ProjectilePool
	if get_node_or_null("CollisionShape2D") == null:
		var shape_node := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 20.0
		shape_node.shape = shape
		add_child(shape_node)
	var art := PixelActor.new()
	art.kind = "sentinel" if enemy_type == 0 else "overseer"
	art.pixel_size = 2.5 if enemy_type == 0 else 4.0
	add_child(art)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player) or _player.dead:
		return
	_timer -= delta
	if use_laser and _timer <= warning_duration:
		if not _charging:
			_aim = global_position.direction_to(_player.global_position)
			_charging = true
		_warning.points = PackedVector2Array([_aim * 24.0, _aim * 1600.0])
		_warning.show()
	modulate = Color(1.8, 0.8, 0.6) if _timer < 0.6 else Color.WHITE
	if _timer <= 0.0:
		_timer = fire_interval
		_fire()
		_charging = false
		_warning.hide()

func _fire() -> void:
	var direction := _aim if use_laser else global_position.direction_to(_player.global_position)
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
	if _dying or amount <= 0.0:
		return
	health -= amount
	if combo_count >= 2:
		_show_combo(combo_count)
	var now := Time.get_ticks_msec()
	if now >= _next_damage_label_ms:
		_next_damage_label_ms = now + 200
		_show_feedback("-%s" % str(snappedf(amount, 0.1)), Color(1.0, 0.8, 0.3))
	if health <= 0.0:
		_dying = true
		_show_feedback("✦", Color(1.0, 0.3, 0.2))
		died.emit()
		queue_free()

func _show_feedback(message: String, color: Color) -> void:
	var scene := get_tree().current_scene
	if not scene:
		return
	var label := Label.new()
	label.text = message
	label.modulate = color
	label.z_index = 100
	scene.add_child(label)
	label.global_position = global_position + Vector2(-12, -36)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 35.0, 0.6)
	tween.tween_property(label, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(label.queue_free)

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
