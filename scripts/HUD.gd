extends CanvasLayer

@onready var _dialogue: DialogueManager = $DialogueManager
@onready var _stamina: ProgressBar = $TopStatusContainer/StaminaBar

func _ready() -> void:
	var portrait := PixelActor.new()
	portrait.kind = "shilda"
	portrait.pixel_size = 3.0
	portrait.position = Vector2(52, 66)
	$DialogueBox.add_child(portrait)
	var speaker := Label.new()
	speaker.text = "SHILDA"
	speaker.position = Vector2(92, 10)
	speaker.modulate = Color("73e6df")
	speaker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$DialogueBox.add_child(speaker)
	var player := get_tree().get_first_node_in_group("Player")
	if player:
		player.stamina_changed.connect(_update_stamina)
		player.health_changed.connect(_update_health)
		$TopStatusContainer/HPBar.show()
		_update_health(player.health)
		_update_stamina(player.stamina, player.max_stamina)
		player.shield_broken.connect(_on_shield_broken)
		player.perfect_parry_combo.connect(_on_perfect_parry_combo)
		player.shield.upgrade_picked.connect(_on_upgrade_picked)
	_dialogue.trigger("on_game_start")

func _update_stamina(value: float, maximum: float) -> void:
	_stamina.max_value = maximum
	_stamina.value = value

func _on_shield_broken() -> void:
	_dialogue.trigger("on_shield_broken")

func _on_perfect_parry_combo(_count: int) -> void:
	_dialogue.trigger("on_perfect_parry_combo")

func _on_upgrade_picked(upgrade_id: String) -> void:
	_dialogue.trigger("on_upgrade_picked", upgrade_id)

func _update_health(value: float) -> void:
	$TopStatusContainer/HPBar.value = value
	$TopStatusContainer/HPBar/HPLabel.text = "CAN %d / 100" % int(value)
