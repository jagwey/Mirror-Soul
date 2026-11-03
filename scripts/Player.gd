extends CharacterBody2D
## Mobile twin-stick player: left half = move/dash, right half = shield aim.

enum State { NORMAL, DASHING, BLOCKING, STUNNED }

signal stamina_changed(value: float, max_value: float)
signal state_changed(new_state: State)
signal health_changed(value: float)
signal died
signal shield_broken
signal perfect_parry_combo(count: int)

@export var move_speed := 260.0
@export var stick_radius := 90.0 ## px of finger travel for full speed
@export_group("Shield Aim")
@export var aim_deadzone := 5.0
@export_range(0.0, 1.0) var aim_immediate_weight := 0.85
@export var aim_smoothing_speed := 35.0
@export_group("Dash")
@export var dash_speed := 900.0
@export var dash_duration := 0.15
@export var double_tap_window := 0.28
@export var swipe_speed := 2200.0 ## drag velocity (px/s) that counts as a swipe
@export var near_miss_radius := 80.0
@export var near_miss_gain := 15.0
@export_group("Stamina")
@export var max_stamina := 100.0
@export var block_drain := 14.0 ## per real second
@export var move_regen := 24.0 ## per second, only shield down + moving
@export var block_hit_cost := 10.0
@export var parry_gain := 25.0
@export var parry_combo_window := 3.0
@export var parry_combo_threshold := 2
@export var stun_time := 2.0
@export_group("Bullet Time")
@export var block_time_scale := 0.4
@export_group("Telekinesis")
@export var min_offset := 30.0
@export var max_offset := 180.0

@onready var shield_pivot: Node2D = $ShieldPivot
@onready var shield: Shield = $ShieldPivot/ShieldArea

var health := 100.0
var _invulnerable_until := 0
var dead := false
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
var _shield_target_angle := 0.0
var _last_parry_ms := -100000
var _parry_combo := 0
var drag_vector := Vector2.ZERO
var telekinetic_offset := 30.0
var _target_offset := 30.0
var _tether: Line2D
var _hitstop := false


func _ready() -> void:
	shield.parried.connect(_on_parried)
	shield.blocked.connect(_on_blocked)
	shield.lower()
	stamina_changed.emit(stamina, max_stamina)
	_tether = Line2D.new()
	_tether.width = 3.0
	_tether.default_color = Color(1.5, 1.8, 2.5, 0.8)
	_tether.z_index = -1
	add_child(_tether)


func _input(event: InputEvent) -> void:
	if dead:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_SPACE:
		_try_dash()
	elif event is InputEventKey and event.physical_keycode == KEY_E and not event.echo:
		if event.pressed:
			drag_vector = get_global_mouse_position() - global_position
			_update_shield_target(drag_vector)
			shield_pivot.rotation = _shield_target_angle
			_raise_shield()
		elif not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_target_offset = min_offset
			_lower_shield(true)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			drag_vector = get_global_mouse_position() - global_position
			_update_shield_target(drag_vector)
			shield_pivot.rotation = _shield_target_angle
			_raise_shield()
		elif not Input.is_physical_key_pressed(KEY_E):
			_target_offset = min_offset
			_lower_shield(true)
	elif event is InputEventMouseMotion and (Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_physical_key_pressed(KEY_E)):
		drag_vector = get_global_mouse_position() - global_position
		_update_shield_target(drag_vector)
		shield_pivot.rotation = lerp_angle(shield_pivot.rotation, _shield_target_angle, aim_immediate_weight)
	elif event is InputEventScreenTouch:
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
			_shield_target_angle = shield_pivot.rotation
			_raise_shield()
	else:
		if e.index == _move_finger:
			_move_finger = -1
			_move_input = Vector2.ZERO
		elif e.index == _shield_finger:
			_shield_finger = -1
			_target_offset = min_offset
			_lower_shield(true)


func _handle_drag(e: InputEventScreenDrag) -> void:
	if e.index == _move_finger:
		_move_input = (e.position - _move_origin).limit_length(stick_radius) / stick_radius
		if e.velocity.length() > swipe_speed:
			_try_dash()
	elif e.index == _shield_finger:
		var aim := e.position - _shield_origin
		if aim.length_squared() >= aim_deadzone * aim_deadzone:
			drag_vector = aim
			_update_shield_target(aim)
			if e.velocity.length() > swipe_speed:
				_target_offset = max_offset
			shield_pivot.rotation = lerp_angle(shield_pivot.rotation, _shield_target_angle, aim_immediate_weight)


func _update_shield_target(aim: Vector2) -> void:
	if aim.length_squared() < aim_deadzone * aim_deadzone:
		return
	_shield_target_angle = aim.angle()
	_target_offset = clampf(min_offset + aim.length() * 0.75, min_offset, max_offset)


func _physics_process(delta: float) -> void:
	if dead:
		return
	if _move_finger == -1:
		_move_input = Vector2(float(Input.is_physical_key_pressed(KEY_D)) - float(Input.is_physical_key_pressed(KEY_A)), float(Input.is_physical_key_pressed(KEY_S)) - float(Input.is_physical_key_pressed(KEY_W))).normalized()
	# Stamina/bullet time run on real time so 0.4x does not slow the drain.
	var real_delta := delta / maxf(Engine.time_scale, 0.001)
	if shield.active:
		var weight := 1.0 - exp(-aim_smoothing_speed * real_delta)
		shield_pivot.rotation = lerp_angle(shield_pivot.rotation, _shield_target_angle, weight)
	telekinetic_offset = lerpf(telekinetic_offset, _target_offset, 1.0 - exp(-12.0 * real_delta))
	shield.position.x = telekinetic_offset
	_tether.points = PackedVector2Array([Vector2.ZERO, to_local(shield.global_position)])
	if _move_input.length_squared() > 0.01:
		facing = _move_input.normalized()

	match state:
		State.DASHING:
			_dash_left -= delta
			velocity = facing * dash_speed
			if _dash_left <= 0.0:
				_set_state(State.NORMAL)
		State.STUNNED:
			velocity = Vector2.ZERO
		State.BLOCKING:
			velocity = _move_input * move_speed
			if not shield.is_perfect_window() and not _hitstop:
				Engine.time_scale = block_time_scale
			_change_stamina(-block_drain * real_delta)
		State.NORMAL:
			velocity = _move_input * move_speed
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
	shield_broken.emit()
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
	var now := Time.get_ticks_msec()
	_parry_combo = _parry_combo + 1 if now - _last_parry_ms <= parry_combo_window * 1000.0 else 1
	_last_parry_ms = now
	if _parry_combo == maxi(2, parry_combo_threshold):
		perfect_parry_combo.emit(_parry_combo)
	_change_stamina(parry_gain)
	screen_shake()
	if _hitstop:
		return
	_hitstop = true
	Engine.time_scale = 0.0
	await get_tree().create_timer(0.05, true, false, true).timeout
	Engine.time_scale = 1.0
	_hitstop = false


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

func take_damage(amount: float) -> void:
	if dead or state == State.DASHING or Time.get_ticks_msec() < _invulnerable_until:
		return
	health = maxf(0.0, health - amount)
	_invulnerable_until = Time.get_ticks_msec() + 700
	shield.reset_combo()
	health_changed.emit(health)
	if health <= 0.0:
		dead = true
		_lower_shield()
		died.emit()

## Continuous damage must not be reduced to one tiny frame by projectile invulnerability.
func take_laser_damage(amount: float) -> void:
	if dead or state == State.DASHING or amount <= 0.0:
		return
	health = maxf(0.0, health - amount)
	shield.reset_combo()
	health_changed.emit(health)
	if health <= 0.0:
		dead = true
		_lower_shield()
		died.emit()
