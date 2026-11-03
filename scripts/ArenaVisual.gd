extends Node2D
var room_index := 1
var floor_index := 1
var exit_open := false
func set_room(floor_value: int, room_value: int, open_exit := false) -> void:
	floor_index = floor_value
	room_index = room_value
	exit_open = open_exit
	queue_redraw()
func _draw() -> void:
	var stone := Color("b5b6a0")
	var dark := Color("090d11")
	draw_rect(Rect2(32, 32, 1216, 656), dark)
	var rng := RandomNumberGenerator.new()
	rng.seed = floor_index * 133 + room_index
	for i in 140:
		var pos := Vector2(rng.randi_range(60, 1210), rng.randi_range(70, 650))
		var tint := Color(0.32, 0.37, 0.35, rng.randf_range(0.06, 0.23))
		draw_line(pos, pos + Vector2(rng.randi_range(3, 18), 0), tint, 2)
	for row in range(3):
		for col in range(32):
			var x := col * 40 + (20 if row % 2 else 0)
			var tint := stone.darkened(float((col + row) % 4) * 0.1)
			draw_rect(Rect2(x, row * 12, 37, 10), tint)
			draw_rect(Rect2(x, 684 + row * 12, 37, 10), tint.darkened(0.2))
	for row in range(3, 57):
		draw_rect(Rect2(0, row * 12, 30, 10), stone.darkened(0.2))
		draw_rect(Rect2(1250, row * 12, 30, 10), stone.darkened(0.2))
	draw_rect(Rect2(38, 40, 1204, 640), stone.darkened(0.65), false, 2)
	var center := Vector2(640, 340)
	var radius := 80 + room_index * 24
	draw_arc(center, radius, 0, TAU, 48, Color(0.45, 0.7, 0.65, 0.15), 2)
	for i in 8:
		var d := Vector2.from_angle(i * TAU / 8)
		draw_line(center + d * (radius - 8), center + d * (radius + 8), Color(0.45, 0.7, 0.65, 0.3), 3)
	# Recessed alcoves sit outside the main combat area.
	for x in [110, 420, 860, 1170]:
		draw_rect(Rect2(x - 25, 40, 50, 45), stone.darkened(0.7))
		draw_rect(Rect2(x - 19, 40, 38, 38), dark)
		draw_rect(Rect2(x - 3, 58, 6, 14), Color("73e6df").darkened(0.3))
	if exit_open:
		draw_rect(Rect2(1170, 290, 68, 100), Color("28494e"))
		for step in 6:
			draw_line(Vector2(1178, 300 + step * 14), Vector2(1230, 300 + step * 14), stone, 4)
		draw_rect(Rect2(1166, 286, 76, 108), Color("73e6df"), false, 2)
