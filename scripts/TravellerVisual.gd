extends Node2D
func _draw() -> void:
	# Integer-sized shapes form an original hooded traveller silhouette.
	draw_rect(Rect2(-12, 8, 24, 12), Color(0.18, 0.22, 0.25))
	draw_rect(Rect2(-10, -2, 20, 18), Color(0.73, 0.76, 0.68))
	draw_rect(Rect2(-12, -18, 24, 20), Color(0.85, 0.85, 0.73))
	draw_rect(Rect2(-8, -12, 16, 10), Color(0.08, 0.11, 0.14))
	draw_rect(Rect2(-5, -9, 3, 3), Color(0.5, 0.9, 0.95))
	draw_rect(Rect2(3, -9, 3, 3), Color(0.5, 0.9, 0.95))
	draw_rect(Rect2(-8, 18, 6, 6), Color(0.75, 0.76, 0.7))
	draw_rect(Rect2(3, 18, 6, 6), Color(0.75, 0.76, 0.7))
