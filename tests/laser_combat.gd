extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	var player = load("res://scenes/Player.tscn").instantiate()
	world.add_child(player)
	player.position = Vector2(200, 200)
	var beam = load("res://scripts/LaserBeam.gd").new()
	beam.damage_per_sec = 20.0
	world.add_child(beam)
	beam.position = Vector2(400, 200)
	beam.rotation = PI
	for i in 35:
		await physics_frame
	assert(player.health < 95.0, "Unblocked laser must deal sustained damage")
	player.shield.raise()
	await physics_frame
	await physics_frame
	var protected_health: float = player.health
	for i in 20:
		await physics_frame
	assert(is_equal_approx(player.health, protected_health), "Active shield must stop laser damage")
	assert(beam.bounces >= 1, "Shield must reflect laser")
	player.shield.lower()
	for i in 10:
		await physics_frame
	assert(player.health < protected_health, "Lowering shield must restore damage")
	print("Sustained laser / shield tests: PASS")
	quit()
