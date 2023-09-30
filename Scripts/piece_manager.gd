extends Node2D

const PIECE = "res://Scenes/Piece.tscn"

const PIECE_SCENE = preload(PIECE)

# Called when the node enters the scene tree for the first time.
func _ready():
	var piece_instance = PIECE_SCENE.instantiate()
	piece_instance.offset_left = 120
	piece_instance.offset_top = 120
	piece_instance.set_position(Vector2(200, 200))
	add_child(piece_instance)
	return piece_instance


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
