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
	collision_layer = 1
	collision_mask = 1
	_shape = CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 5.0
	_shape.shape = circle
	add_child(_shape)
	body_entered.connect(_on_body_entered)

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
	global_position += velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		pool.recycle(self)

func _on_body_entered(body: Node2D) -> void:
	if not in_use:
		return
	if body.is_in_group("Enemy") and not reflected:
		return
	if body.is_in_group("Player") and reflected:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	pool.recycle(self)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 5.0, Color(2, 2, 2) if reflected else Color(2, 0.15, 0.15))
