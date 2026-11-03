extends Node2D
## Three encounters per floor, then a reward and an explicit stair interaction.
var floor_number := 1
var encounter := 0
var remaining := 0
var waiting := false
var room_cleared := false
var _label: Label
var _button: Button
var _panel: VBoxContainer

func _ready() -> void:
	_label = Label.new()
	_label.position = Vector2(790, 48)
	_label.add_theme_font_size_override("font_size", 19)
	$HUD.add_child(_label)
	_button = Button.new()
	_button.text = "ÜST KATA ÇIK"
	_button.position = Vector2(540, 110)
	_button.size = Vector2(200, 50)
	_button.hide()
	$HUD.add_child(_button)
	_button.pressed.connect(_next_floor)
	var help := Label.new()
	help.text = "WASD: hareket  •  E / sağ tık: kalkan  •  Fare: yön ve mesafe  •  Boşluk: dash"
	help.position = Vector2(290, 690)
	help.add_theme_font_size_override("font_size", 15)
	help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$HUD.add_child(help)
	$Player.died.connect(_game_over)
	_start_encounter.call_deferred()

func _start_encounter() -> void:
	if $Player.dead:
		return
	room_cleared = false
	encounter += 1
	$ArenaVisual.set_room(floor_number, encounter)
	_label.text = "KAT %d  •  ODA %d / 3" % [floor_number, encounter]
	remaining = 4
	var positions := [Vector2(250, 180), Vector2(1000, 180), Vector2(1000, 490), Vector2(250, 490)]
	for i in remaining:
		var enemy := Enemy.new()
		enemy.max_health = 18.0 + (floor_number - 1) * 10.0
		enemy.use_laser = true
		enemy.initial_delay = 2.5 + i * 1.6
		enemy.fire_interval = maxf(4.0, 7.2 - (floor_number - 1) * 0.5 - (encounter - 1) * 0.3)
		enemy.warning_duration = maxf(0.65, 1.1 - floor_number * 0.05)
		enemy.laser_duration = 1.35
		enemy.projectile_damage = 18.0 + minf(12.0, floor_number * 2.0)
		enemy.projectile_speed = minf(330.0, 150.0 + floor_number * 20.0)
		enemy.enemy_type = 1 if floor_number >= 3 and i == 0 else 0
		enemy.position = positions[i]
		enemy.died.connect(_enemy_died)
		add_child(enemy)

func _enemy_died() -> void:
	remaining -= 1
	if remaining > 0 or $Player.dead:
		return
	_clear_bullets.call_deferred()
	if encounter < 3:
		room_cleared = true
		$ArenaVisual.set_room(floor_number, encounter, true)
		_label.text = "Oda temiz. Sağdaki geçide ilerle."
	else:
		_offer_rewards.call_deferred()

func _clear_bullets() -> void:
	for beam in get_tree().get_nodes_in_group("CombatLaser"):
		beam.queue_free()
	for projectile in $ProjectilePool.get_children():
		if projectile.in_use:
			$ProjectilePool.recycle(projectile)

func _offer_rewards() -> void:
	_label.text = "Kat temiz. Shilda için bir biçim seç."
	_panel = VBoxContainer.new()
	_panel.position = Vector2(410, 160)
	_panel.size = Vector2(460, 200)
	$HUD.add_child(_panel)
	var choices := [0, 1, 2, 3]
	choices.shuffle()
	var ids := ["prism", "focus", "auto_aim", "ghost"]
	for kind in choices.slice(0, 3):
		var button := Button.new()
		var info: Dictionary = $HUD/DialogueManager.get_upgrade_info(ids[kind])
		button.text = str(info.get("name", ids[kind])) + "\n" + str(info.get("description", ""))
		button.custom_minimum_size = Vector2(460, 65)
		button.pressed.connect(_choose.bind(kind))
		_panel.add_child(button)

func _choose(kind: int) -> void:
	if waiting:
		return
	waiting = true
	var upgrade := MirrorUpgrade.new()
	upgrade.kind = kind
	$Player.shield.apply_upgrade(upgrade)
	_panel.queue_free()
	_button.show()
	$Player.health = minf(100.0, $Player.health + 30.0)
	$Player.health_changed.emit($Player.health)

func _next_floor() -> void:
	floor_number += 1
	encounter = 0
	waiting = false
	_button.hide()
	$Player.position = Vector2(640, 400)
	_start_encounter()

func _game_over() -> void:
	_clear_bullets.call_deferred()
	_label.text = "Shilda: Anlaşmamız henüz bitmedi."
	if is_instance_valid(_panel):
		_panel.queue_free()
	_button.show()
	_button.text = "YENİDEN DENE"
	_button.pressed.disconnect(_next_floor)
	_button.pressed.connect(func(): get_tree().reload_current_scene())

func _physics_process(_delta: float) -> void:
	if room_cleared and not $Player.dead and $Player.position.distance_to(Vector2(1200, 340)) < 68.0:
		room_cleared = false
		$Player._lower_shield()
		$Player.position = Vector2(120, 340)
		$Player.stamina = $Player.max_stamina
		$Player.stamina_changed.emit($Player.stamina, $Player.max_stamina)
		_start_encounter.call_deferred()
