extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	current_scene = world
	var player = load("res://scenes/Player.tscn").instantiate()
	world.add_child(player)
	await physics_frame
	var shield: Shield = player.shield
	shield.raise()
	var beams: Array[Node] = []
	for i in 8:
		var beam = load("res://scripts/LaserBeam.gd").new()
		world.add_child(beam)
		beam.set_physics_process(false)
		beams.append(beam)
		shield.laser_contact(beam, 0.016)
		shield.laser_contact(beam, 0.016)
		assert(shield.reflection_combo == i + 1, "Repeated beam contact must count only once")
	await process_frame
	assert(is_equal_approx(shield.scale.x, 1.8), "Combo size must stop at 1.8x")
	shield.release_laser(beams[0])
	shield.laser_contact(beams[0], 0.016)
	assert(shield.reflection_combo == 9, "Returning beam contact should count")
	shield.reset_combo()
	await process_frame
	assert(shield.reflection_combo == 0 and is_equal_approx(shield.scale.x, 1.0), "Damage reset should restore size")
	print("Shield combo tests: PASS")
	quit()
