extends Area2D

signal score_piece

@export var GRID_WIDTH  = 10
@export var GRID_HEIGHT = 10
@export var BLOCKER_COUNT = 3  ## How many blockers are placed onto the grid initially
@export var BLOCKER_SIZE = 4  ## How many squares each blocker is (default)
#FF: variable size blockers

const TILE_SRC = 1 #board_tiles.png
# GRID Layers
const LAYER_BASE = 0
const LAYER_FOOD = 1

const ORTHAGONAL_DIRS = [
	Vector2i(0,-1), #up
	Vector2i(1, 0), #right
	Vector2i(0, 1), #down
	Vector2i(-1, 0) #left
]

var TILE_TYPES = {
	"empty": Vector2(0,0),
	"blocked": Vector2(1, 0),
	"scoring": Vector2(2, 0),
	"special_1": Vector2(0, 1),
	"special_2": Vector2(1, 1),
	"special_3": Vector2(2, 1),
	"basic": Vector2(3,3),
	"advanced": Vector2(2,3)
}

const FOODS = {
	"": 0,
	"basic": 1,
	"advanced": 2,
	"blocked": 3
}

@export var bag_contents := {
	"scoring": 40,
	"special_1": 1,
	"special_2": 1,
	"special_3": 1
}

var unscored_specials = []
var scored_specials = []

const OFFSCREEN = Vector2(-9999,-9999) ## Used for spawning pieces where player doesn't need to see them

func _ready():
	if []:
		print("empty array is truthy")
	randomize_board()
	place_blockers()

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
	
	scored_specials = []
	unscored_specials = []
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var tile_type = tile_bag.pop_back()
			if tile_type in ["special_1", "special_2", "special_3"]:
				unscored_specials.append(Vector2i(x, y))
			var tile_atlas = TILE_TYPES[tile_type]
			# Set the tile at (x, y) to TILE_SQUARE
			$PlateGrid.set_cell(
				LAYER_BASE,     # Layer ID
				Vector2i(x, y), # Coordinates
				TILE_SRC,    # Tile ID source
				tile_atlas # Atlas coords
			)

func place_blockers():
	
	#TODO: check for illegal placement (both initial and grow)
	### INC. code for better blocker placement
	for i in range(BLOCKER_COUNT):
		# Place "advanced" pieces as blockers
		var blk = get_node("../PieceManager").make_piece_at(OFFSCREEN, "advanced")
		var possible_locs = []
		for x in range(GRID_WIDTH):
			for y in range(GRID_HEIGHT):
				possible_locs.append(Vector2i(x,y))
		possible_locs.shuffle()
		while possible_locs:
			if not possible_locs.size():
				print("oh shit, out of legal placements for blocker #", i)
				break
			var loc = possible_locs.pop_back()
			# TBD: cells2d?
			var cells_placed = test_piece_placement(loc, blk.piece.cells, "blocked")
			if not cells_placed.size():
				continue # try another loc
			else:
				for cell in cells_placed:
					put_food_at("blocked", cell)
				break

# ##OLD blocker placement code
#		var loc
#		while true:
#			loc = Vector2i(randi_range(0,GRID_WIDTH), randi_range(0,GRID_HEIGHT))
#			if oob(loc) or scoring_at(loc) > 0 or food_color_at(loc) == 3:
#				# try again if out of bounds or would overwrite a special or blocker
#				continue
#			break
#		put_food_at("blocked", loc)
#		for j in range(BLOCKER_SIZE-1):
#			var new_loc
#			var dirs_to_try = ORTHAGONAL_DIRS.duplicate()
#			dirs_to_try.shuffle()
#			var failed_to_grow = false
#			while true:
#				new_loc = loc + dirs_to_try.pop_back()
#				if oob(new_loc) or scoring_at(new_loc) > 0 or food_color_at(new_loc) == 3:
#					if not dirs_to_try.size():
#						print("Nowhere to grow blocker...")
#						failed_to_grow = true
#						break
#					continue
#				break
#			#TODO: do something about failing to grow the blockers
#			loc = new_loc
#			put_food_at("blocked", loc)

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

func adacent_to_color(coords: Vector2i, color: String) -> bool:
	var color_i = FOODS[color]
	for d in ORTHAGONAL_DIRS:
		var chk_coords = coords + d
		if food_color_at(chk_coords) == color_i:
			return true
	return false

func is_encircled(coords: Vector2i):
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
	
func check_for_circled_specials() -> Array[Vector2i]:
	var new_scores : Array[Vector2i] = []
	for i in range(unscored_specials.size() - 1, -1, -1): # backwards so we can pop safely
		if is_encircled(unscored_specials[i]):
			var score = unscored_specials.pop_at(i)
			new_scores.append(score)
			scored_specials.append(score)
			print("Woo! Scored a special @", score)
	return new_scores
		
			

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse Click at: ", event.position)
		var map_coords = map_coords_of(event.position)
		print("Points:",scoring_at(map_coords))
		print("Encircled?:", is_encircled(map_coords))
		#cycle_food_at(map_coords)

func test_piece_placement(base_coords:Vector2i, cells2d: Array, color: String) -> Array:
	## Really the return type is Array[Vector2i] except sometimes it's empty
	var q_change = []
	for dx in range(cells2d.size()):
		for dy in range(cells2d[dx].size()):
			if not cells2d[dx][dy]:
				# not a filled cell
				continue
			var cell_coords = base_coords + Vector2i(dx, dy)
		
			if oob(cell_coords):
				print("oob piece drop @ square", cell_coords)
				return []
			if is_occupied(cell_coords):
				print("blocked @", cell_coords)
				return []
			if adacent_to_color(cell_coords, color):
				print("adjacency problem @", cell_coords)
				return []
			q_change.append(cell_coords)
	return q_change

func _on_piece_drop(pos: Vector2i, piece: Piece):
	var coords = map_coords_of(pos, true) # based on top left corner of piece hitbox
	var color : String = piece.piece.type
	#TODO: handle rotation, maybe some other stuff
	
	var bump_score = 0
	var cells2d : Array = piece.piece.cells#TODO: piece.piece.cells?? ### grumble, "nested typed collections" like Array[Array[int]] aren't supported
	print(cells2d)
	var q_change = test_piece_placement(coords, cells2d, color)
	
	if not q_change.size():
		return
	
	for set_coords in q_change:
		put_food_at(color, set_coords)
		if scoring_at(set_coords) == 1: # Regular space, add to score
			bump_score += piece.score_value()
	if bump_score:
		emit_signal("score_piece", bump_score)
	
	var _scored_specials = check_for_circled_specials()
	#TODO: actually do score and animation stuff
	
	# snap piece's actual position & make it 
	piece.position = (Vector2i(piece.position+Vector2(30,30)) / Vector2i(60,60)) * Vector2i(60,60) #TODO: fix magic numbers
	piece.input_pickable = false
	piece.modulate.a = 0.4 # temp, for visibility
	piece.remove_from_group("Unplaced Pieces")
		
	print(pos, piece)
