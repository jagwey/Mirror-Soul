extends Node2D
## Continuous beam; each branch has a bounded number of reflections.
signal combo(bounces: int)
const RED := Color(2.0, 0.2, 0.2)
const PURE := Color(2.0, 2.0, 2.0)
@export var max_length := 2000.0
@export var max_bounces := 4
@export var damage_per_sec := 20.0
@export var width := 4.0
@export var duration := 0.0 ## 0 = continuous
var burst_damage := 0.0
var friendly := false
var purified := false
var bounces := 0
var _ray := RayCast2D.new()
var _lines: Array[Line2D] = []
var _burst_hits: Dictionary = {}
var _last_shields: Array[Node] = []

func _ready() -> void:
	add_to_group("CombatLaser")
	_ray.top_level = true
	_ray.enabled = false
	_ray.collide_with_areas = true
	_ray.collide_with_bodies = true
	_ray.collision_mask = 1
	add_child(_ray)

func _physics_process(delta: float) -> void:
	for line in _lines:
		line.visible = false
	var branches: Array[Dictionary] = [{"origin": global_position, "dir": global_transform.x.normalized(), "count": 0, "pure": friendly, "exclude": null}]
	var line_index := 0
	var max_seen := 0
	var touched := false
	var current_shields: Array[Node] = []
	while not branches.is_empty() and line_index < 32:
		var branch: Dictionary = branches.pop_back()
		var origin: Vector2 = branch.origin
		var direction: Vector2 = branch.dir
		_ray.clear_exceptions()
		if is_instance_valid(branch.exclude):
			_ray.add_exception(branch.exclude)
		_ray.global_position = origin
		_ray.global_rotation = 0.0
		_ray.target_position = direction * max_length
		_ray.force_raycast_update()
		var hit: Object = _ray.get_collider() if _ray.is_colliding() else null
		var point: Vector2 = _ray.get_collision_point() if hit else origin + direction * max_length
		var line := _get_line(line_index)
		line_index += 1
		line.points = PackedVector2Array([origin, point])
		line.default_color = PURE if branch.pure else RED
		line.visible = true
		var count: int = branch.count
		max_seen = maxi(max_seen, count)
		if hit is Node and hit.is_in_group("Shield") and hit.active:
			touched = true
			if hit not in current_shields:
				current_shields.append(hit)
			var pure: bool = hit.laser_contact(self, delta) or branch.pure
			if hit.absorbs_laser() or count >= max_bounces:
				continue
			var bounce: Vector2 = direction.bounce(hit.reflection_normal())
			for next_dir in hit.reflection_directions(bounce, point):
				branches.append({"origin": point + next_dir * 0.5, "dir": next_dir, "count": count + 1, "pure": pure, "exclude": hit})
		elif hit is Node and hit.is_in_group("ReflectiveWall") and count < max_bounces:
			var bounce: Vector2 = direction.bounce(_ray.get_collision_normal())
			branches.append({"origin": point + bounce * 0.5, "dir": bounce, "count": count + 1, "pure": branch.pure, "exclude": hit})
		elif hit is Node:
			var enemy := DamageTarget.enemy_from(hit)
			if enemy and count == 0 and not friendly:
				continue
			var target: Node = enemy if enemy else hit
			if not target.has_method("take_damage"):
				continue
			var amount: float = damage_per_sec * (3.0 if branch.pure and not friendly else 1.0) * delta
			if burst_damage > 0.0:
				if _burst_hits.has(target.get_instance_id()):
					continue
				_burst_hits[target.get_instance_id()] = true
				amount = burst_damage
			if enemy:
				DamageTarget.apply_enemy_damage(enemy, amount, count + 1 if count > 0 else 0)
			elif target.has_method("take_laser_damage"):
				target.take_laser_damage(amount)
			else:
				target.take_damage(amount)
	for shield in _last_shields:
		if is_instance_valid(shield) and shield not in current_shields and shield.has_method("release_laser"):
			shield.release_laser(self)
	_last_shields = current_shields
	if not touched:
		purified = false
	if max_seen != bounces:
		bounces = max_seen
		combo.emit(bounces)
	if duration > 0.0:
		duration -= delta
		if duration <= 0.0:
			queue_free()

func _get_line(index: int) -> Line2D:
	while _lines.size() <= index:
		var line := Line2D.new()
		line.top_level = true
		line.width = width
		add_child(line)
		_lines.append(line)
	return _lines[index]

func _exit_tree() -> void:
	for shield in _last_shields:
		if is_instance_valid(shield) and shield.has_method("release_laser"):
			shield.release_laser(self)
