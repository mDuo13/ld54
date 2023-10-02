extends Node2D

const PIECE = "res://scenes/piece.tscn"

const PIECE_SCENE = preload(PIECE)
const MARGIN = 20
const PIECE_HEIGHT = 120
const PIECE_WIDTH = 240

const BAG_CONTENTS = {
	"basic": 2,
	"advanced": 2
}

var CART_START
var SCREEN_HEIGHT

# Called when the node enters the scene tree for the first time.
func _ready():
	CART_START = $Cart.position
	SCREEN_HEIGHT = get_viewport_rect().size.y
	make_bag()

func make_piece_at(coords, piecetype:String = "") -> Piece:
	var piece_instance = PIECE_SCENE.instantiate()
	piece_instance.ready_pieces_by_type()
	piece_instance.set_piece_type(piecetype)
	piece_instance.set_position(coords)
	add_child(piece_instance)
	piece_instance.connect("piece_drop", get_node("../Plate")._on_piece_drop)
	piece_instance.connect("piece_move", get_node("../Plate")._on_piece_move)
	piece_instance.add_to_group("Unplaced Pieces")
	return piece_instance

func add_piece(piecetype:String = "") -> void:
	# Note: this piece count doesn't work as we want if we freed pieces this frame
	var piece_count = get_tree().get_nodes_in_group("Unplaced Pieces").size()
	var offset = Vector2(MARGIN + PIECE_WIDTH/2, MARGIN + (piece_count*PIECE_HEIGHT) + (piece_count*MARGIN) + PIECE_HEIGHT/2)
	make_piece_at($Cart.position + offset, piecetype)

func make_bag() -> Array:
	var coords = $Cart.position + Vector2(MARGIN + PIECE_WIDTH/2, MARGIN+PIECE_HEIGHT/2)
	var pieces = []
	for t in BAG_CONTENTS:
		for i in range(BAG_CONTENTS[t]):
			pieces.append(make_piece_at(coords, t))
			coords += Vector2(0, (PIECE_HEIGHT)+MARGIN)
	return pieces


func _on_pass_butt_pressed():
	advance_cart()


func advance_cart():
	ScoreSaver.turns += 1
	get_node("../UI/PassButt").disabled =true
	var tween = get_tree().create_tween()
	tween.tween_property($Cart, "position", Vector2($Cart.position.x, $Cart.position.y-SCREEN_HEIGHT), 0.2)
	tween.tween_callback(refresh_cart)
	var leftovers = get_tree().get_nodes_in_group("Unplaced Pieces")
	for p in leftovers:
		var ptw = get_tree().create_tween()
		ptw.tween_property(p, "position", Vector2(p.position.x, p.position.y-SCREEN_HEIGHT), 0.2)

func refresh_cart():
	$Cart.position.y = CART_START.y+SCREEN_HEIGHT
	get_tree().call_group("Unplaced Pieces", "queue_free")
	var pieces = make_bag()
	var tween = get_tree().create_tween()
	tween.tween_property($Cart, "position", CART_START, 0.2)
	for p in pieces:
		var ptw = get_tree().create_tween()
		ptw.tween_property(p, "position", Vector2(p.position.x, p.position.y-SCREEN_HEIGHT), 0.2)


func _on_plate_placed_piece():
	var piece_count = get_tree().get_nodes_in_group("Unplaced Pieces").size()
	if piece_count < 1:
		advance_cart()
