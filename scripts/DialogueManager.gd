class_name DialogueManager
extends Node
## Non-blocking, bounded queue. JSON text is plain text, never interpreted as BBCode.
@export_file("*.json") var dialogue_file := "res://resources/dialogues.tr.json"
@export var characters_per_second := 45.0
@export var hold_seconds := 2.5
@export var max_queue := 8
@export var panel_path: NodePath
@export var text_path: NodePath
var _data: Dictionary = {}
var _queue: Array[String] = []
var _cursor: Dictionary = {}
var _characters := 0.0
var _hold_left := 0.0
var _showing := false
@onready var _panel: Control = get_node(panel_path)
@onready var _text: RichTextLabel = get_node(text_path)

func _ready() -> void:
	_panel.hide()
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_text.bbcode_enabled = false
	if not FileAccess.file_exists(dialogue_file):
		push_warning("Dialogue file missing: " + dialogue_file)
		return
	var json := JSON.new()
	var err := json.parse(FileAccess.get_file_as_string(dialogue_file))
	if err != OK or not (json.data is Dictionary):
		push_warning("Invalid dialogue JSON: %s (line %d)" % [json.get_error_message(), json.get_error_line()])
		return
	_data = json.data

func trigger(event: String, upgrade_id := "") -> void:
	var events: Variant = _data.get("dialogues", {})
	if not (events is Dictionary):
		return
	var lines: Variant = events.get(event, [])
	if event == "on_upgrade_picked":
		if not (lines is Dictionary):
			return
		lines = lines.get(upgrade_id, [])
	if not (lines is Array) or lines.is_empty():
		return
	var key := event + ":" + upgrade_id
	var index: int = int(_cursor.get(key, 0)) % lines.size()
	_cursor[key] = index + 1
	var message: Variant = lines[index]
	if not (message is String) or message.strip_edges().is_empty():
		return
	if _queue.size() >= max_queue:
		return
	_queue.append(message)
	if not _showing:
		_show_next()

func get_upgrade_info(upgrade_id: String) -> Dictionary:
	var upgrades: Variant = _data.get("upgrades", {})
	if upgrades is Dictionary:
		var info: Variant = upgrades.get(upgrade_id, {})
		if info is Dictionary:
			return info
	return {}

func _show_next() -> void:
	if _queue.is_empty():
		_showing = false
		_panel.hide()
		return
	_showing = true
	_text.text = _queue.pop_front()
	_text.visible_characters = 0
	_characters = 0.0
	_hold_left = hold_seconds
	_panel.show()

func _process(delta: float) -> void:
	if not _showing:
		return
	# Dialogue uses real time even when blocking slows the game.
	var real_delta := delta / maxf(Engine.time_scale, 0.001)
	var total := _text.get_total_character_count()
	if _text.visible_characters < total:
		_characters += maxf(characters_per_second, 1.0) * real_delta
		_text.visible_characters = mini(int(_characters), total)
	else:
		_hold_left -= real_delta
		if _hold_left <= 0.0:
			_show_next()
