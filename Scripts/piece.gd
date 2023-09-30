extends CharacterBody2D

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
			1, 0, 0, 0
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

func _ready():
	var piece = pieces[pieces.keys()[randi() % pieces.size()]]
	get_node("Sprite2D").texture = piece["image"]
	get_node("CollisionPolygon2D").polygon = piece["vertices"]

func _process(delta):
	if (mouse_over && !dragging && Input.is_action_pressed("select")):
		offset = to_local(get_viewport().get_mouse_position())
		dragging = true
	if (dragging && Input.is_action_pressed("select")):
		set_position(get_viewport().get_mouse_position() - offset)
	else:
		dragging = false

func _mouse_enter():
	mouse_over = true

func _mouse_exit():
	mouse_over = false
