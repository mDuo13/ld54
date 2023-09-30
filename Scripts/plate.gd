extends Area2D

@export var GRID_WIDTH  = 10
@export var GRID_HEIGHT = 10
@export var BLOCKER_COUNT = 3  ## How many blockers are placed onto the grid initially
@export var BLOCKER_SIZE = 4  ## How many squares each blocker is (default)
#FF: variable size blockers

const TILE_SRC = 1 #board_tiles.png
# GRID Layers
const LAYER_BASE = 0
const LAYER_FOOD = 1

enum FOOD {NONE, PINK, GREEN, BLOCK} # matches the values used in the color data layer
const GROW_VECS = [
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
	"food_pink": Vector2(3,3),
	"food_green": Vector2(2,3)
}

@export var bag_contents := {
	"scoring": 40,
	"special_1": 1,
	"special_2": 1,
	"special_3": 1
}

func _ready():
	randomize_board()
	place_blockers()

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
	
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			var tile_type = tile_bag.pop_back()
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
	for i in range(BLOCKER_COUNT):
		var loc
		while true:
			loc = Vector2i(randi_range(0,GRID_WIDTH), randi_range(0,GRID_HEIGHT))
			if loc.x < 0 or loc.y < 0 or loc.x >= GRID_WIDTH or loc.y >= GRID_WIDTH:
				continue # out of bounds, try again
			if scoring_at(loc) > 1 or food_color_at(loc) == 3:
				continue # don't overwrite bonus spaces or other blockers
			break
		put_food_at("blocked", loc)
		for j in range(BLOCKER_SIZE-1):
			var new_loc
			while true:
				new_loc = loc + GROW_VECS[randi()%GROW_VECS.size()]
				if new_loc.x < 0 or new_loc.y < 0 or new_loc.x >= GRID_WIDTH or new_loc.x >= GRID_HEIGHT:
					continue
				if scoring_at(new_loc) > 1 or food_color_at(new_loc) == 3:
					continue
				break
			loc = new_loc
			put_food_at("blocked", loc)

func scoring_at(coords: Vector2i):
	var cell_data = $PlateGrid.get_cell_tile_data(LAYER_BASE, coords)
	if not cell_data:
		return 0
	var scoring = cell_data.get_custom_data("scoring")
	return scoring

func food_color_at(coords: Vector2i):
	var cell_data = $PlateGrid.get_cell_tile_data(LAYER_FOOD, coords)
	if not cell_data:
		return 0
	return cell_data.get_custom_data("color")

func put_food_at(food : String, coords: Vector2i):
	var food_tile = TILE_TYPES[food]
	$PlateGrid.set_cell(LAYER_FOOD, coords, TILE_SRC, food_tile)

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("Mouse Click at: ", event.position)
		var map_coords = $PlateGrid.local_to_map( to_local(event.position) )
		print(scoring_at(map_coords))
