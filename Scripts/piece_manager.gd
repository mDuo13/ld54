extends Node2D

const PIECE = "res://Scenes/Piece.tscn"

const PIECE_SCENE = preload(PIECE)
const MARGIN = 20
const PIECE_HEIGHT = 120
const PIECE_WIDTH = 240

const BAG_CONTENTS = {
	"basic": 2,
	"advanced": 2
}

# Called when the node enters the scene tree for the first time.
func _ready():
	make_bag()

func make_piece_at(coords, piecetype:String = "") -> Piece:
	var piece_instance = PIECE_SCENE.instantiate()
	piece_instance.ready_pieces_by_type()
	piece_instance.set_piece_type(piecetype)
	piece_instance.set_position(coords)
	add_child(piece_instance)
	piece_instance.connect("piece_drop", get_node("../Plate")._on_piece_drop)
	piece_instance.add_to_group("Unplaced Pieces")
	return piece_instance

func add_piece(piecetype:String = "") -> void:
	# Note: this piece count doesn't work as we want if we freed pieces this frame
	var piece_count = get_tree().get_nodes_in_group("Unplaced Pieces").size()
	var offset = Vector2(MARGIN + PIECE_WIDTH/2, MARGIN + (piece_count*PIECE_HEIGHT) + (piece_count*MARGIN) + PIECE_HEIGHT/2)
	make_piece_at($Cart.position + offset, piecetype)

func make_bag() -> void:
	var coords = $Cart.position + Vector2(MARGIN + PIECE_WIDTH/2, MARGIN+PIECE_HEIGHT/2)
	for t in BAG_CONTENTS:
		for i in range(BAG_CONTENTS[t]):
			make_piece_at(coords, t)
			coords += Vector2(0, (PIECE_HEIGHT)+MARGIN)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_pass_butt_pressed():
	get_tree().call_group("Unplaced Pieces", "queue_free")
	make_bag()
	get_node("../UI/PassButt").disabled =true

