class_name ProjectilePool
extends Node2D

@export var initial_size := 128
var _free: Array[PooledProjectile] = []

func _ready() -> void:
	add_to_group("ProjectilePool")
	for i in initial_size:
		_create_projectile()

func _create_projectile() -> PooledProjectile:
	var projectile := PooledProjectile.new()
	add_child(projectile)
	projectile.pool = self
	projectile.deactivate()
	_free.append(projectile)
	return projectile

func spawn_shot(pos: Vector2, direction: Vector2, speed: float, damage: float, friendly := false) -> PooledProjectile:
	if _free.is_empty():
		return null
	var projectile: PooledProjectile = _free.pop_back()
	projectile.activate(pos, direction, speed, damage, friendly)
	return projectile

func recycle(projectile: PooledProjectile) -> void:
	if not projectile.in_use:
		return
	projectile.deactivate()
	_free.append(projectile)
