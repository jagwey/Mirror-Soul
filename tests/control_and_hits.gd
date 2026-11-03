extends SceneTree

var failures := 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, message: String) -> void:
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	var player = load("res://scenes/Player.tscn").instantiate()
	world.add_child(player)
	player.global_position = Vector2(200, 200)
	await physics_frame
	var touch := InputEventScreenTouch.new()
	touch.index = 7
	touch.position = Vector2(900, 300)
	touch.pressed = true
	player._input(touch)
	check(player.shield.active and player.state == player.State.BLOCKING, "Shield did not open")
	var drag := InputEventScreenDrag.new()
	drag.index = 7
	drag.position = Vector2(900, 350)
	player._input(drag)
	check(player.shield_pivot.rotation > 1.0, "Relative drag did not turn the shield promptly")
	touch.pressed = false
	player._input(touch)
	check(not player.shield.active and player.state == player.State.NORMAL, "Shield did not close on release")
	player.shield_pivot.rotation = 0.0
	player.shield.raise()
	var enemy := Enemy.new()
	enemy.max_health = 1.0
	world.add_child(enemy)
	enemy.global_position = Vector2(400, 200)
	var beam = load("res://scripts/LaserBeam.gd").new()
	beam.damage_per_sec = 1000.0
	world.add_child(beam)
	beam.global_position = Vector2(377, 200)
	beam.global_rotation = PI
	for i in 12:
		await physics_frame
	check(not is_instance_valid(enemy) or enemy.is_queued_for_deletion(), "Reflected laser did not kill enemy")
	beam.queue_free()
	player.shield.lower()
	var pool := ProjectilePool.new()
	pool.initial_size = 2
	world.add_child(pool)
	var hurt_enemy := Enemy.new()
	hurt_enemy.max_health = 5.0
	hurt_enemy.collision_layer = 0
	world.add_child(hurt_enemy)
	hurt_enemy.global_position = Vector2(500, 300)
	var hurtbox := Area2D.new()
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 15.0
	shape.shape = circle
	hurtbox.add_child(shape)
	hurt_enemy.add_child(hurtbox)
	await physics_frame
	pool.spawn_shot(Vector2(450, 300), Vector2.RIGHT, 300.0, 10.0, true)
	for i in 30:
		await physics_frame
	check(not is_instance_valid(hurt_enemy) or hurt_enemy.is_queued_for_deletion(), "Reflected projectile did not damage Area2D hurtbox")
	var laser_enemy := Enemy.new()
	laser_enemy.max_health = 1.0
	laser_enemy.collision_layer = 0
	world.add_child(laser_enemy)
	laser_enemy.global_position = Vector2(600, 400)
	var laser_hurtbox := Area2D.new()
	var laser_shape := CollisionShape2D.new()
	var laser_circle := CircleShape2D.new()
	laser_circle.radius = 15.0
	laser_shape.shape = laser_circle
	laser_hurtbox.add_child(laser_shape)
	laser_enemy.add_child(laser_hurtbox)
	await physics_frame
	var friendly_beam = load("res://scripts/LaserBeam.gd").new()
	friendly_beam.friendly = true
	friendly_beam.burst_damage = 5.0
	world.add_child(friendly_beam)
	friendly_beam.global_position = Vector2(550, 400)
	for i in 8:
		await physics_frame
	check(not is_instance_valid(laser_enemy) or laser_enemy.is_queued_for_deletion(), "Laser did not damage Area2D hurtbox")
	friendly_beam.queue_free()
	print("Control and hit tests: ", "PASS" if failures == 0 else "FAIL (%d)" % failures)
	quit(0 if failures == 0 else 1)



