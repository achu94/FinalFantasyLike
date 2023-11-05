extends Node2D

# AstarGrid2D is a methode for path finding.
@onready var astar_grid: AStarGrid2D = AStarGrid2D.new()

# Drag Tilemap from the to the specific input in the right Inspector section
# @export var tile_map: TileMap

# Tileset
@onready var tile_map = $"../TileMap"
# Fast way to set the speed from the Inspector section
@export var speed: int = 80
# Grid cell size
@export var grid_cell_size_x: int = 32
@export var grid_cell_size_y: int = 32

# Current wallking path in the array
var current_id_path: Array[Vector2i]

# Current target position
var target_position: Vector2

# is moving flag
var is_moving: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	dependencyCheck()
	initMovableArea()

func _physics_process(delta):
	move(delta)

func dependencyCheck() -> void:
	# Check Tilemap
	assert(tile_map != null, 'Tilemap is not set')

func initMovableArea() -> void:
	# Getting every grid area
	astar_grid.region = tile_map.get_used_rect()
	print(tile_map.get_used_rect())
	# Setting the cell size each grid
	astar_grid.cell_size = Vector2(grid_cell_size_x, grid_cell_size_y)
	# Setting of the behavior of astar.
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	# Setting up the astar grid ist finished.
	astar_grid.update()
	
	# loop every tilemap cell
	for x in tile_map.get_used_rect().size.x:
		for y in tile_map.get_used_rect().size.y:
			var tile_position = Vector2i(
				x + tile_map.get_used_rect().position.x,
				y + tile_map.get_used_rect().position.x,
			)
			
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("walkable") == false:
				astar_grid.set_point_solid(tile_position)

# Evenet handler
func _input(event):
	# in the first stage, the event handler will be responsive only for move.
	if event.is_action_pressed("m_left_click") == false:
		return
	
	# it has to finish his target, bevor moving to the next target
	var from_path = target_position if is_moving else global_position
	
	# path to move
	var id_path := astar_grid.get_id_path(
		tile_map.local_to_map(from_path),
		tile_map.local_to_map(get_global_mouse_position())
	).slice(1)
	
	# When clicked_pos is not empty, the walking path will be settet.
	if id_path.is_empty() == false:
		current_id_path = id_path

func move(delta):
	# Check if current position to move is not empty
	if current_id_path.is_empty():
		return
	
	# setting the target position, only the next grid in the array
	if is_moving == false:
		target_position = tile_map.map_to_local(current_id_path.front())
		is_moving = true
	
	# moving
	global_position = global_position.move_toward(target_position, (speed * delta))
	
	# after reach the target, removing the reached index
	if global_position == target_position:
		current_id_path.pop_front()
		
		if current_id_path.is_empty() == false:
			target_position = tile_map.map_to_local(current_id_path.front())
		else:
			is_moving = false
