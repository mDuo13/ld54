extends CharacterBody2D
class_name Piece

signal piece_drop

var pieces = {
	"2" : {
		"image" : preload("res://Assets/2_Piece.png"),
		"vertices" : [
			Vector2(0, 0),
			Vector2(120, 0),
			Vector2(120, 60),
			Vector2(0, 60)
		],
		"cells" : [
			1, 1
		],
		"type" : "basic"
	},
	"3" : {
		"image" : preload("res://Assets/3_Piece.png"),
		"vertices" : [
			Vector2(0, 0),
			Vector2(120, 0),
			Vector2(120, 120),
			Vector2(60, 120),
			Vector2(60, 60),
			Vector2(0, 60)
		],
		"cells" : [
			1, 1, 0, 0,
			0, 1, 0, 0 # Rome's note: I changed this to match the sprite
		],
		"type" : "basic"
	},
	"L" : {
		"image" : preload("res://Assets/L_Piece.png"),
		"vertices" : [
			Vector2(0, 0),
			Vector2(180, 0),
			Vector2(180, 60),
			Vector2(60, 60),
			Vector2(60, 120),
			Vector2(0, 120)
		],
		"cells" : [
			1, 1, 1, 0,
			1, 0, 0, 0
		],
		"type" : "advanced"
	},
	"J" : {
		"image" : preload("res://Assets/J_Piece.png"),
		"vertices" : [
			Vector2(0, 0),
			Vector2(180, 0),
			Vector2(180, 120),
			Vector2(120, 120),
			Vector2(120, 60),
			Vector2(0, 60)
		],
		"cells" : [
			1, 1, 1, 0,
			0, 0, 1, 0
		],
		"type" : "advanced"
	},
	"T" : {
		"image" : preload("res://Assets/T_Piece.png"),
		"vertices" : [
			Vector2(0, 0),
			Vector2(180, 0),
			Vector2(180, 60),
			Vector2(120, 60),
			Vector2(120, 120),
			Vector2(60, 120),
			Vector2(60, 60),
			Vector2(0, 60)
		],
		"cells" : [
			1, 1, 1, 0,
			0, 1, 0, 0
		],
		"type" : "advanced"
	},
	"S" : {
		"image" : preload("res://Assets/S_Piece.png"),
		"vertices" : [
			Vector2(60, 0),
			Vector2(180, 0),
			Vector2(180, 60),
			Vector2(120, 60),
			Vector2(120, 120),
			Vector2(0, 120),
			Vector2(0, 60)
		],
		"cells" : [
			0, 1, 1, 0,
			1, 1, 0, 0
		],
		"type" : "advanced"
	},
	"Z" : {
		"image" : preload("res://Assets/Z_Piece.png"),
		"vertices" : [
			Vector2(0, 0),
			Vector2(120, 0),
			Vector2(120, 60),
			Vector2(180, 60),
			Vector2(180, 120),
			Vector2(60, 120),
			Vector2(60, 60),
			Vector2(0, 60)
		],
		"cells" : [
			1, 1, 0, 0,
			0, 1, 1, 0
		],
		"type" : "advanced"
	},
	"I" : {
		"image" : preload("res://Assets/I_Piece.png"),
		"vertices" : [
			Vector2(0, 0),
			Vector2(180, 0),
			Vector2(180, 60),
			Vector2(0, 60)
		],
		"cells" : [
			1, 1, 1, 1,
			0, 0, 0, 0
		],
		"type" : "advanced"
	},
	"O" : {
		"image" : preload("res://Assets/O_Piece.png"),
		"vertices" : [
			Vector2(0, 0),
			Vector2(120, 0),
			Vector2(120, 120),
			Vector2(0, 120)
		],
		"cells" : [
			1, 1, 0, 0,
			1, 1, 0, 0
		],
		"type" : "advanced"
	}
}

var mouse_over = false
var dragging = false
var offset = Vector2(0, 0)
var piece

var by_type = {}

func _ready():
	ready_pieces_by_type()
	if not piece:
		set_piece()

func ready_pieces_by_type():
	for p in pieces:
		if pieces[p].type in by_type.keys():
			by_type[pieces[p].type].append(p)
		else:
			by_type[pieces[p].type] = [p]

func set_piece(p: String = ""):
	if not p:
		p = pieces.keys()[randi() % pieces.size()]
	piece = pieces[p]
	get_node("Sprite2D").texture = piece["image"]
	get_node("CollisionPolygon2D").polygon = piece["vertices"]

func set_piece_type(t: String = ""):
	if not t:
		t = by_type.keys()[randi() % by_type.size()]
	var p = by_type[t][randi() % by_type[t].size()]
	set_piece(p)

func score_value():
	if piece.type == "basic":
		return 1
	else:
		return 2

func _process(_delta):
	if (mouse_over && !dragging && Input.is_action_just_pressed("select")):
		offset = to_local(get_viewport().get_mouse_position())
		dragging = true
	if (dragging && Input.is_action_pressed("select")):
		set_position(get_viewport().get_mouse_position() - offset)
	else:
		if dragging == true:
			emit_signal("piece_drop", position, self)
		dragging = false

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
