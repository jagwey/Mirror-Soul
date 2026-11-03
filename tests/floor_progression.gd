extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var scene = load("res://scenes/TestDungeon.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	assert(scene.remaining == 4)
	# Resolve the third encounter directly to exercise reward -> next floor.
	scene.encounter = 3
	for enemy in get_nodes_in_group("Enemy"):
		enemy.take_damage(10000.0)
	await process_frame
	await process_frame
	assert(is_instance_valid(scene._panel))
	scene._choose(1)
	assert(scene.get_node("Player").shield.focus_enabled)
	scene._next_floor()
	assert(scene.floor_number == 2 and scene.remaining == 4)
	scene.get_node("Player").take_damage(1000.0)
	assert(scene.get_node("Player").dead)
	assert(scene._button.text == "YENİDEN DENE")
	print("Floor progression: PASS")
	quit()
