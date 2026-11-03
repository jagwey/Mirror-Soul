extends SceneTree
func _initialize() -> void:
	_run.call_deferred()
func _run() -> void:
	var scene = load("res://scenes/TestDungeon.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await create_timer(1.0).timeout
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("user://preview.png")
	quit()
