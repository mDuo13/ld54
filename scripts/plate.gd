extends Area2D

signal score_piece
signal placed_piece
signal score_bonus
signal start_game

@export var GRID_WIDTH  = 10
@export var GRID_HEIGHT = 10
@export var BLOCKER_COUNT = 3  ## How many blockers are placed onto the grid initially
@export var BONUS_MULTIPLIER = 3

const TILE_SRC = 1 #board_tiles.png
# GRID Layers
const LAYER_BASE = 0
const LAYER_FOOD = 1
const LAYER_X = 2

const ORTHAGONAL_DIRS = [
	Vector2i(0,-1), #up
	Vector2i(1, 0), #right
	Vector2i(0, 1), #down
	Vector2i(-1, 0) #left
]

var TILE_TYPES = {
	"empty": Vector2(0,0),
	"blocked": Vector2(1, 3),
	"scoring": Vector2(1, 0),
	"scoring_2": Vector2(2, 0),
	"scoring_3": Vector2(3, 0),
	"special_1": Vector2(0, 1),
	"special_2": Vector2(1, 1),
	"special_3": Vector2(2, 1),
	"basic": Vector2(3,3),
	"advanced": Vector2(2,3),
	"xmark": Vector2(0,2),
	"shiny": Vector2(1,2)
}

const FOODS = {
	"": 0,
	"basic": 1,
	"advanced": 2,
	"blocked": 3
}

@export var bag_contents := {
	"scoring": 13,
	"scoring_2": 13,
	"scoring_3": 13,
	"special_1": 1,
	"special_2": 1,
	"special_3": 1
}

var SCORE_PARTICLES = preload("res://scenes/particles_1.tscn")

var unscored_specials = {}
var scored_specials = []

const OFFSCREEN = Vector2(-9999,-9999) ## Used for spawning pieces where player doesn't need to see them

func _ready():
	randomize_board()
	place_blockers()
	AudioManager.start_game()
	ScoreSaver.reset()

func oob(coords: Vector2i) -> bool:
	if coords.x < 0 or coords.y < 0 or coords.x >= GRID_WIDTH or coords.y >= GRID_HEIGHT:
		return true
	return false

func randomize_board():
	var tile_bag = []
	for tile_type in bag_contents:
		for i in range(bag_contents[tile_type]):
			tile_bag.append(tile_type)
	if tile_bag.size() < GRID_WIDTH * GRID_HEIGHT:
		var spaces_to_add = GRID_WIDTH*GRID_HEIGHT - tile_bag.size()
		print("Adding", spaces_to_add, "empty spaces to complete the bag")
		for i in range(spaces_to_add):
			tile_bag.append("empty")
	elif tile_bag.size() > GRID_WIDTH * GRID_HEIGHT:
		print("Bag contains", GRID_WIDTH * GRID_HEIGHT - tile_bag.size(), "tiles more than there's room for")
	tile_bag.shuffle()
	
	scored_specials = {}
	unscored_specials = {}
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var tile_type = tile_bag.pop_back()
			if tile_type in ["special_1", "special_2", "special_3"]:
				unscored_specials[tile_type] = {
					"coords": Vector2i(x, y),
					"pieces": []
				}
			var tile_atlas = TILE_TYPES[tile_type]
			# Set the tile at (x, y) to TILE_SQUARE
			$PlateGrid.set_cell(
				LAYER_BASE,     # Layer ID
				Vector2i(x, y), # Coordinates
				TILE_SRC,    # Tile ID source
				tile_atlas # Atlas coords
			)

func place_blockers():
	for i in range(BLOCKER_COUNT):
		# Place "advanced" pieces as blockers
		var blk = get_node("../PieceManager").make_piece_at(OFFSCREEN, "advanced")
		blk.change_to_blocker()
		var possible_locs = []
		for x in range(GRID_WIDTH):
			for y in range(GRID_HEIGHT):
				possible_locs.append(Vector2i(x,y))
		possible_locs.shuffle()
		while possible_locs:
			if not possible_locs.size():
				print("oh no, out of legal placements for blocker #", i)
				break
			var loc = possible_locs.pop_back()
			var cells_placed = test_piece_placement(loc, blk.piece.cells, "blocked", true)
			if not cells_placed.size():
				continue # try another loc
			else:
				for cell in cells_placed:
					put_food_at("blocked", cell)
				blk.position = to_global($PlateGrid.map_to_local(loc))
				blk.snap()
				blk.lock()
				break
	wipe_xs()

func scoring_at(coords: Vector2i):
	var cell_data = $PlateGrid.get_cell_tile_data(LAYER_BASE, coords)
	if not cell_data:
		return 0
	var scoring = cell_data.get_custom_data("scoring")
	return scoring

func food_color_at(coords: Vector2i) -> int:
	var cell_data = $PlateGrid.get_cell_tile_data(LAYER_FOOD, coords)
	if not cell_data:
		return 0
	return cell_data.get_custom_data("color")

func is_occupied(coords: Vector2i) -> bool:
	return food_color_at(coords) != 0

func put_food_at(food : String, coords: Vector2i):
	var food_tile = TILE_TYPES[food]
	$PlateGrid.set_cell(LAYER_FOOD, coords, TILE_SRC, food_tile)

func make_shiny(coords: Vector2i):
	$PlateGrid.set_cell(LAYER_FOOD, coords, TILE_SRC, TILE_TYPES["shiny"])

func adjacent_to_color(coords: Vector2i, color: String) -> bool:
	var color_i = FOODS[color]
	for d in ORTHAGONAL_DIRS:
		var chk_coords = coords + d
		if food_color_at(chk_coords) == color_i:
			return true
	return false

func is_encircled(coords: Vector2i):
	#TODO: check that this doesn't allow overlap & fix ifso
	assert (not oob(coords))
	var gap_found = false
	for dx in range(-1, 2):
		for dy in range(-1,2):
			if dx==0 and dy==0:
				continue #skip self
			var newloc = coords + Vector2i(dx, dy)
			if oob(newloc):
				continue # edges work for encircling
			if scoring_at(newloc) > 1: #special spaces work
				continue
			if food_color_at(newloc) > 0:
				continue
			# No valid encircler there!
			gap_found = true
			break
	return not gap_found

func cycle_food_at(coords: Vector2i): #debug helper
	var food_color = food_color_at(coords) + 1
	if food_color > 3:#max food num
		food_color = 0
		$PlateGrid.erase_cell(LAYER_FOOD, coords)
	else:
		$PlateGrid.set_cell(LAYER_FOOD, coords, TILE_SRC, TILE_TYPES[FOODS.keys()[food_color]])


func map_coords_of(global_coords: Vector2i, smoothing=false) -> Vector2i:
	if smoothing:
		global_coords += Vector2i(30,30)#TODO: fix magic number
	return $PlateGrid.local_to_map( to_local(global_coords) )


func check_for_circled_specials():
	var new_scores = {}
	##for i in range(unscored_specials.size() - 1, -1, -1): # backwards so we can pop safely
	for sname in unscored_specials.keys(): # only safe to remove from dict if we iterate over keys()
		var special = unscored_specials[sname]
		if is_encircled(special.coords):
			new_scores[sname] = special
			scored_specials[sname] = special
			unscored_specials.erase(sname)
			print("Woo! Scored a special @", special.coords)
			make_shiny(special.coords)
			animate_particles(special.coords, "special")
			AudioManager.add_bonus_track(sname)
			emit_signal("score_bonus", sname, special)


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse Click at: ", event.position)
		var map_coords = map_coords_of(event.position)
		print("Points:",scoring_at(map_coords))
		print("Encircled?:", is_encircled(map_coords))
		#cycle_food_at(map_coords)


func test_piece_placement(base_coords:Vector2i, cells2d: Array, color: String, dont_overlap_specials=true) -> Array:
	## Really the return type is Array[Vector2i] except sometimes it's empty
	var q_change = []
	var failed_check = false
	for dy in range(cells2d.size()):
		for dx in range(cells2d[dy].size()):
			if not cells2d[dy][dx]:
				# not a filled cell
				continue
			var cell_coords = base_coords + Vector2i(dx, dy)
			if oob(cell_coords):
				#print("oob piece drop @ square", cell_coords)
				#set_x_at(cell_coords) # Don't put extra x's because it's overkill if the piece isn't near the board
				failed_check = true
			if is_occupied(cell_coords):
				#print("blocked @", cell_coords)
				set_x_at(cell_coords)
				failed_check = true
			if adjacent_to_color(cell_coords, color):
				#print("adjacency problem @", cell_coords)
				set_x_at(cell_coords)
				failed_check = true
			if dont_overlap_specials and scoring_at(cell_coords) > 1:
				#print("not supposed to overlap special @", cell_coords)
				set_x_at(cell_coords)
				failed_check = true
			q_change.append(cell_coords)
	if failed_check:
		return []
	return q_change


func set_x_at(coords):
	$PlateGrid.set_cell(LAYER_X, coords, TILE_SRC, TILE_TYPES["xmark"])


func wipe_xs():
	$PlateGrid.clear_layer(LAYER_X)


func _on_piece_drop(_pos: Vector2i, piece: Piece):
	var coords = map_coords_of(piece.top_left())
	print("dropping piece at map coords", coords)
	var color : String = piece.piece.type
	
	var bump_score = 0
	var cells2d : Array = piece.piece.cells ### grumble, "nested typed collections" like Array[Array[int]] aren't supported
	var q_change = test_piece_placement(coords, cells2d, color)
	
	if not q_change.size():
		return
	
	for set_coords in q_change:
		put_food_at(color, set_coords)
		if scoring_at(set_coords) == 1: # Regular space, add to score
			bump_score += piece.score_value()
			ScoreSaver.symbols_scored += 1
			animate_particles(set_coords, color)
		notify_adjacent_specials(set_coords, piece)
	if bump_score:
		piece.points_scored = bump_score
		ScoreSaver.total_score += bump_score
		if piece.piece.type == "basic":
			AudioManager.sfx(AudioManager.DING_SM)
			ScoreSaver.sweets_scored += bump_score
		else: #piece.piece.type=="advanced"
			ScoreSaver.savory_scored += bump_score
			AudioManager.sfx(AudioManager.DING_MD)
		emit_signal("score_piece", bump_score)
	check_for_circled_specials()
	piece.lock()
	emit_signal("placed_piece")
	

func coords_adjacent(v1: Vector2i, v2: Vector2i):
	return (abs(v2-v1) <= Vector2i(1,1))


## Add this piece to the tracking list for any adjacent unscored specials so
## that this piece can be re-scored when the special is encircled
func notify_adjacent_specials(coords, piece) -> void:
	for sname in unscored_specials.keys():
		var sp = unscored_specials[sname]
		if coords_adjacent(sp.coords, coords):
			if piece not in sp.pieces:
				sp.pieces.append(piece)


func animate_particles(coords: Vector2i, type="basic") -> void:
	var emitter = SCORE_PARTICLES.instantiate()
	$PlateGrid.add_child(emitter)
	emitter.position = $PlateGrid.map_to_local(coords)
	emitter.set_type(type)

func _on_piece_move():
	wipe_xs()


func _on_score_bonus(_special_name, special_deets):
	var points_added = 0
	for piece in special_deets.pieces:
		points_added += piece.points_scored * (BONUS_MULTIPLIER-1)
		piece.sparkle()
	ScoreSaver.specials_scored += 1
	ScoreSaver.points_from_specials += points_added
	ScoreSaver.total_score += points_added
	AudioManager.sfx(AudioManager.DING_LG)
	if points_added:
		emit_signal("score_piece", points_added)

