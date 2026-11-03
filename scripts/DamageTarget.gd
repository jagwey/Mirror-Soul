class_name DamageTarget
extends RefCounted
## Resolve either an Enemy collision object or a child hurtbox to its damage receiver.
static func enemy_from(collider: Node) -> Node:
	var node := collider
	var enemy_group_seen := false
	while is_instance_valid(node):
		enemy_group_seen = enemy_group_seen or node.is_in_group("Enemy")
		if enemy_group_seen and node.has_method("take_damage"):
			return node
		# The group and damage method can both live on a parent of the hurtbox.
		if node.is_in_group("Enemy") and node.has_method("take_damage"):
			return node
		node = node.get_parent()
	return null

static func apply_enemy_damage(target: Node, amount: float, combo_count := 0) -> void:
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		return
	if target is Enemy:
		target.take_damage(amount, combo_count)
	else:
		target.take_damage(amount)
