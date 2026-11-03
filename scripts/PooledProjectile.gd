class_name PooledProjectile
extends Area2D

var pool: ProjectilePool
var velocity := Vector2.ZERO
var damage := 10.0
var reflected := false
var in_use := false
var lifetime := 0.0
var _shape: CollisionShape2D

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	_shape = CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	_shape.shape = circle
	add_child(_shape)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func activate(pos: Vector2, direction: Vector2, speed: float, amount: float, friendly: bool) -> void:
	global_position = pos
	velocity = direction.normalized() * speed
	damage = amount
	reflected = friendly
	in_use = true
	lifetime = 6.0
	visible = true
	modulate = Color.WHITE
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	if not friendly:
		add_to_group("EnemyProjectile")
	queue_redraw()

func deactivate() -> void:
	in_use = false
	visible = false
	remove_from_group("EnemyProjectile")
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

func _physics_process(delta: float) -> void:
	if not in_use:
		return
	var next_position := global_position + velocity * delta
	# A swept ray catches small hurtboxes crossed between physics frames.
	if reflected and velocity.length_squared() > 0.0:
		var query := PhysicsRayQueryParameters2D.create(global_position, next_position, 1)
		query.collide_with_areas = true
		var exclusions: Array[RID] = []
		for node in get_tree().get_nodes_in_group("Player") + get_tree().get_nodes_in_group("Shield"):
			if node is CollisionObject2D:
				exclusions.append(node.get_rid())
		query.exclude = exclusions
		var hit := get_world_2d().direct_space_state.intersect_ray(query)
		if not hit.is_empty():
			var collider: Object = hit.collider
			var enemy := DamageTarget.enemy_from(collider) if collider is Node else null
			if enemy:
				global_position = hit.position
				DamageTarget.apply_enemy_damage(enemy, damage)
				pool.recycle(self)
				return
			if collider is Node and collider.is_in_group("ReflectiveWall"):
				pool.recycle(self)
				return
	global_position = next_position
	lifetime -= delta
	if lifetime <= 0.0:
		pool.recycle(self)
		return
	# Fast reflected shots can skip enter signals; overlap scan is the fallback.
	if reflected and monitoring:
		for other in get_overlapping_bodies() + get_overlapping_areas():
			var enemy := DamageTarget.enemy_from(other)
			if enemy:
				DamageTarget.apply_enemy_damage(enemy, damage)
				pool.recycle(self)
				return

func _on_body_entered(body: Node2D) -> void:
	if not in_use:
		return
	var enemy := DamageTarget.enemy_from(body)
	if enemy:
		if reflected:
			DamageTarget.apply_enemy_damage(enemy, damage)
			pool.recycle(self)
		return
	if body.is_in_group("Player") and reflected:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	pool.recycle(self)

func _on_area_entered(area: Area2D) -> void:
	if not in_use or not reflected:
		return
	var enemy := DamageTarget.enemy_from(area)
	if enemy:
		DamageTarget.apply_enemy_damage(enemy, damage)
		pool.recycle(self)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(2, 2, 2) if reflected else Color(2, 0.15, 0.15))
