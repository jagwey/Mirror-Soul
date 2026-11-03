class_name PixelActor
extends Node2D
@export_enum("traveller", "sentinel", "overseer", "shilda") var kind := "traveller"
@export var pixel_size := 2.0
var _clock := 0.0
var _frame := 0
const PALETTE := {"o": Color("10161c"), "w": Color("e1debf"), "g": Color("7f8c86"), "c": Color("73e6df"), "b": Color("28494e"), "r": Color("ff5269"), "p": Color("aa86d8")}
const ART := {
"traveller": ["......gggg......", "....ggwwwwgg....", "...gwwwwwwwwg...", "..gwwwoooowwwg..", "..gwoooooooowg..", "..gwoocooocowg..", "...gwoooooowg...", "....gwwwwwwg....", "...ggbwccwbgg...", "..gwwbwccwbwwg..", "..gwwbwwwwbwwg..", "...ggbwwwwbgg...", "....gbwwwwbg....", "...gbwwwwwwbg...", "..gbwwwwwwwwbg..", "..gggggggggggg..", "....gg....gg....", "...www....www..."],
"sentinel": [".......ww.......", "......wggw......", ".....wgbbgw.....", "....wgbbbbgw....", "...wgbboobbgw...", "..wgbboooobbgw..", ".wgbboorroobbgw.", "wgbboorrrroobbgw", ".wgbboorroobbgw.", "..wgbboooobbgw..", "...wgbboobbgw...", "....wgbbbbgw....", "...wwggggggww...", "..wgggwwwwgggw..", "..wwwwwwwwwwww..", "...gggggggggg..."],
"overseer": [".......pp.......", "....pppwwppp....", "..ppwwggggwwpp..", ".pwgggoooogggwp.", "pwggwoooooowggwp", "wggwooppppoowggw", "wggwoppooppowggw", "wggwoppooppowggw", "wggwooppppoowggw", "pwggwoooooowggwp", ".pwgggoooogggwp.", "..ppwwggggwwpp..", "....pppwwppp....", ".......pp......."],
"shilda": ["....wwwwwwww....", "..wwggggggggww..", ".wggbbbbbbbbggw.", "wggbbbbbbbbbbggw", "wgbbwwbbbbwwbbgw", "wgbwccwbbwccwbgw", "wgbbwwbbbbwwbbgw", "wgbbbbbbbbbbbbgw", ".wgbbbwwwwbbbgw.", ".wgbbwbbbbwbbgw.", "..wgbbwwwwbbgw..", "...wgbbbbbbgw...", "....wgbbbbgw....", ".....wgbbgw.....", "......wggw......", ".......ww......."]}
func _process(delta: float) -> void:
	_clock += delta
	if _clock >= 0.125:
		_clock = 0.0
		_frame += 1
		queue_redraw()
func _draw() -> void:
	var rows: Array = ART[kind]
	var bob := 0.0
	if kind == "traveller" and get_parent() is CharacterBody2D and get_parent().velocity.length_squared() > 1:
		bob = float(_frame % 2) * pixel_size
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			var key := row.substr(x, 1)
			if PALETTE.has(key):
				draw_rect(Rect2((x - 8) * pixel_size, (y - rows.size() / 2.0) * pixel_size + bob, pixel_size, pixel_size), PALETTE[key])
