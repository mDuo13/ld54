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
		"type" : "basic",
		"points" : 1
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
		"type" : "basic",
		"points" : 1
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
		"type" : "advanced",
		"points" : 2
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
		"type" : "advanced",
		"points" : 2
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
		"type" : "advanced",
		"points" : 2
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
		"type" : "advanced",
		"points" : 2
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
		"type" : "advanced",
		"points" : 2
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
		"type" : "advanced",
		"points" : 2
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
		"type" : "advanced",
		"points" : 2
	}
}

var mouse_over = false
var dragging = false
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
	$Sprite2D.texture = piece["image"]
	$CollisionPolygon2D.polygon = piece["vertices"]

func set_piece_type(t: String = ""):
	if not t:
		t = by_type.keys()[randi() % by_type.size()]
	var p = by_type[t][randi() % by_type[t].size()]
	set_piece(p)

func score_value():
	return piece.piece["points"]

func _process(_delta):
	if (mouse_over && !dragging && Input.is_action_just_pressed("select")):
		dragging = true
	if (dragging && Input.is_action_pressed("select")):
		set_position(get_viewport().get_mouse_position())
	else:
		if dragging == true:
			emit_signal("piece_drop", position, self)
		dragging = false
	if dragging == true && Input.is_action_just_pressed("rotate_clockwise"):
		self.rotation += PI / 2
		
	if dragging == true && Input.is_action_just_pressed("rotate_counterclockwise"):
		self.rotation -= PI / 2

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
