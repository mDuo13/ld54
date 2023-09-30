extends TileMap

const GRID_WIDTH  = 10
const GRID_HEIGHT = 10

const TILE_SQUARE = 0
#const TILE_SQUARE = 1

func _ready():
	for x in range(GRID_WIDTH):
		for y in range(GRID_HEIGHT):
			# Set the tile at (x, y) to TILE_SQUARE
			set_cell(
				0,              # Layer ID
				Vector2i(x, y), # Coordinates
				TILE_SQUARE,    # Tile ID
				Vector2i(0, 0)  # For Atlas
			)

func _process(delta):
	pass
