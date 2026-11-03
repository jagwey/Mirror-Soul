extends SceneTree
var failures := 0
func _initialize() -> void:
	_run.call_deferred()
func check(ok: bool, message: String) -> void:
	if not ok:
		failures += 1
		push_error(message)
func _run() -> void:
	var scene = load("res://scenes/TestDungeon.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	await process_frame
	var player = scene.get_node("Player")
	var manager: DialogueManager = scene.get_node("HUD/DialogueManager")
	var panel: Control = scene.get_node("HUD/DialogueBox")
	var label: RichTextLabel = scene.get_node("HUD/DialogueBox/DialogueText")
	check(panel.visible and label.text.begins_with("Ben Shilda."), "Starting dialogue missing")
	check(not paused and panel.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Dialogue blocks play")
	manager._process(0.2)
	check(label.visible_characters > 0 and label.visible_characters < label.get_total_character_count(), "Typewriter failed")
	player._on_parried()
	player._on_parried()
	check(manager._queue.has("Aynayı bük. Hepsini tek noktaya odakla."), "Parry combo dialogue missing")
	player.shield.raise()
	player._set_state(player.State.BLOCKING)
	player._change_stamina(-1000.0)
	check(manager._queue.has("Kalkan kırıldı. Kendine güvenin de aynı malzemeden mi?"), "Shield break dialogue missing")
	var upgrade := MirrorUpgrade.new()
	for kind in [MirrorUpgrade.Kind.PRISM, MirrorUpgrade.Kind.FOCUS, MirrorUpgrade.Kind.AUTO_AIM, MirrorUpgrade.Kind.GHOST]:
		upgrade.kind = kind
		player.shield.apply_upgrade(upgrade)
	for expected in ["Prizma mı? Bir hatanı artık beş farklı açıdan izleyebilirim.", "İçine at, içine at... Patlayınca hata raporunu ben yazmam.", "Otomatik nişan. Parmakların sendikaya mı girdi?", "Bir kopyan daha oldu. Test ekibi buna hazır mıydı?"]:
		check(manager._queue.has(expected), "Upgrade dialogue missing: " + expected)
	check(manager.get_upgrade_info("focus").get("name", "") == "Kavisli Cam", "Upgrade text missing")
	manager.trigger("unknown_event")
	print("Dialogue tests: ", "PASS" if failures == 0 else "FAIL")
	quit(0 if failures == 0 else 1)
