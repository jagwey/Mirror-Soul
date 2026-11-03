extends CharacterBody2D
## Mobile twin-stick player: left half = move/dash, right half = shield aim.

enum State { NORMAL, DASHING, BLOCKING, STUNNED }

signal stamina_changed(value: float, max_value: float)
signal state_changed(new_state: State)

@export var move_speed := 260.0
@export var stick_radius := 90.0 ## px of finger travel for full speed
@export_group("Dash")
@export var dash_speed := 900.0
@export var dash_duration := 0.15
@export var double_tap_window := 0.28
@export var swipe_speed := 2200.0 ## drag velocity (px/s) that counts as a swipe
@export var near_miss_radius := 80.0
@export var near_miss_gain := 15.0
@export_group("Stamina")
@export var max_stamina := 100.0
@export var block_drain := 35.0 ## per real second
@export var move_regen := 12.0 ## per second, only shield down + moving
@export var block_hit_cost := 10.0
@export var parry_gain := 25.0
@export var stun_time := 2.0
@export_group("Bullet Time")
@export var block_time_scale := 0.4

@onready var shield_pivot: Node2D = $ShieldPivot
@onready var shield: Shield = $ShieldPivot/ShieldArea

var state := State.NORMAL
var stamina := max_stamina
var facing := Vector2.RIGHT

var _move_finger := -1
var _move_origin := Vector2.ZERO
var _move_input := Vector2.ZERO
var _last_left_tap_ms := -1000
var _shield_finger := -1
var _shield_origin := Vector2.ZERO
var _dash_left := 0.0


func _ready() -> void:
	shield.parried.connect(_on_parried)
	shield.blocked.connect(_on_blocked)
	shield.lower()
	stamina_changed.emit(stamina, max_stamina)


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)


func _handle_touch(e: InputEventScreenTouch) -> void:
	var left_side := e.position.x < get_viewport().get_visible_rect().size.x * 0.5
	if e.pressed:
		if left_side and _move_finger == -1:
			_move_finger = e.index
			_move_origin = e.position
			var now := Time.get_ticks_msec()
			if now - _last_left_tap_ms < double_tap_window * 1000.0:
				_try_dash()
			_last_left_tap_ms = now
		elif not left_side and _shield_finger == -1:
			_shield_finger = e.index
			_shield_origin = e.position
			_raise_shield()
	else:
		if e.index == _move_finger:
			_move_finger = -1
			_move_input = Vector2.ZERO
		elif e.index == _shield_finger:
			_shield_finger = -1
			_lower_shield(true)


func _handle_drag(e: InputEventScreenDrag) -> void:
	if e.index == _move_finger:
		_move_input = (e.position - _move_origin).limit_length(stick_radius) / stick_radius
		if e.velocity.length() > swipe_speed:
			_try_dash()
	elif e.index == _shield_finger:
		var aim := e.position - _shield_origin
		if aim.length_squared() > 100.0:
			shield_pivot.rotation = aim.angle()


func _physics_process(delta: float) -> void:
	# Stamina/bullet time run on real time so 0.4x does not slow the drain.
	var real_delta := delta / maxf(Engine.time_scale, 0.001)
	if _move_input.length_squared() > 0.01:
		facing = _move_input.normalized()

	match state:
		State.DASHING:
			_dash_left -= delta
			velocity = facing * dash_speed
			if _dash_left <= 0.0:
				_set_state(State.BLOCKING if _shield_finger != -1 else State.NORMAL)
		State.STUNNED:
			velocity = Vector2.ZERO
		State.BLOCKING:
			velocity = _move_input * move_speed
			if not shield.is_perfect_window():
				Engine.time_scale = block_time_scale
			_change_stamina(-block_drain * real_delta)
		State.NORMAL:
			velocity = _move_input * move_speed
			if velocity != Vector2.ZERO:
				_change_stamina(move_regen * real_delta)
	move_and_slide()


func _try_dash() -> void:
	if state == State.STUNNED or state == State.DASHING:
		return
	shield.leave_ghost()
	if state == State.BLOCKING:
		_lower_shield()
	_dash_left = dash_duration
	_set_state(State.DASHING)
	# Near-miss reward: dashing close to enemy bullets refills stamina.
	var r2 := near_miss_radius * near_miss_radius
	for p in get_tree().get_nodes_in_group("EnemyProjectile"):
		if p is Node2D and global_position.distance_squared_to(p.global_position) < r2:
			_change_stamina(near_miss_gain)


func _raise_shield() -> void:
	if state != State.NORMAL or stamina <= 0.0:
		return
	shield.raise()
	_set_state(State.BLOCKING)


func _lower_shield(fire_focus := false) -> void:
	shield.lower(fire_focus)
	Engine.time_scale = 1.0
	if state == State.BLOCKING:
		_set_state(State.NORMAL)


func _change_stamina(amount: float) -> void:
	stamina = clampf(stamina + amount, 0.0, max_stamina)
	stamina_changed.emit(stamina, max_stamina)
	if stamina <= 0.0 and state == State.BLOCKING:
		_break_guard()


func _break_guard() -> void:
	_shield_finger = -1
	shield.lower()
	Engine.time_scale = 1.0
	_set_state(State.STUNNED)
	await get_tree().create_timer(stun_time, true, false, true).timeout
	if state == State.STUNNED:
		_set_state(State.NORMAL)


func _set_state(s: State) -> void:
	if state == s:
		return
	state = s
	state_changed.emit(s)


func _on_parried() -> void:
	Engine.time_scale = 1.0
	_change_stamina(parry_gain)
	screen_shake()


func _on_blocked() -> void:
	_change_stamina(-block_hit_cost)


## No Camera2D in the scene, so shake the canvas transform directly.
func screen_shake(strength := 8.0, duration := 0.15) -> void:
	var vp := get_viewport()
	var base := vp.canvas_transform
	var t := 0.0
	while t < duration:
		var ct := base
		ct.origin += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * (1.0 - t / duration)
		vp.canvas_transform = ct
		await get_tree().process_frame
		t += get_process_delta_time() / maxf(Engine.time_scale, 0.001)
	vp.canvas_transform = base
