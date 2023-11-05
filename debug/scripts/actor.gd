extends Node2D

# AstarGrid2D is a methode for path finding.
@onready var astar_grid: AStarGrid2D = AStarGrid2D.new()
# Drag Tilemap from the to the specific input in the right Inspector section
@export var tile_map: TileMap
# Fast way to set the speed from the Inspector section
@export var speed: int = 100
# Grid cell size
@export var grid_cell_size: int = 16

# Called when the node enters the scene tree for the first time.
func _ready():
	dependencyCheck()
	initMovableArea()

func dependencyCheck() -> void:
	# Check Tilemap
	assert(tile_map != null, 'Tilemap is not set')

func initMovableArea() -> void:
	# Getting every grid area
	astar_grid.region = tile_map.get_used_rect()
	# Setting the cell size each grid
	astar_grid.cell_size = Vector2(grid_cell_size, grid_cell_size)
	# Setting of the behavior of astar.
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	# Setting up the astar grid ist finished.
	astar_grid.update()
