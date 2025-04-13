extends Node2D

@onready var minerals: TileMapLayer = $Minerals

const MAP_WIDTH = 69
const MAP_HEIGHT = 37
const ORES_ID = 2
const ORE1_POS = Vector2i(4,14)
const ORE1_DEPLETED_POS = Vector2i(6,14)
const ORE2_POS = Vector2i(4,15)
const ORE2_DEPLETED_POS = Vector2i(6,15)
const ORE3_POS = Vector2i(4,16)
const ORE3_DEPLETED_POS = Vector2i(6,16)
const ORE4_POS = Vector2i(4,17)
const ORE4_DEPLETED_POS = Vector2i(6,17)
const STONE_POS = Vector2i(17,13)

func _ready() -> void:
	for i in range(20):
		var rand_x = randi() % MAP_WIDTH +1
		var rand_y = randi() % MAP_HEIGHT +1
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, ORE1_POS)
	for i in range(15):
		var rand_x = randi() % MAP_WIDTH +1
		var rand_y = randi() % MAP_HEIGHT +1
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, ORE2_POS)
	for i in range(10):
		var rand_x = randi() % MAP_WIDTH +1
		var rand_y = randi() % MAP_HEIGHT +1
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, ORE3_POS)
	for i in range(5):
		var rand_x = randi() % MAP_WIDTH +1
		var rand_y = randi() % MAP_HEIGHT +1
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, ORE4_POS)
	for i in range(50):
		var rand_x = randi() % MAP_WIDTH + 1
		var rand_y = randi() % MAP_HEIGHT + 1 
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, STONE_POS)
		

# This function is called on any input event (mouse, keyboard, etc.)
func _input(event: InputEvent) -> void:
	# Check for a left-mouse click
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Get the mouse position in world coordinates
		var mouse_pos = get_global_mouse_position()

		# Convert that to the tilemap's local space
		var local_pos = minerals.to_local(mouse_pos)	
		# Convert local space to tile coordinates
		var tile_coords = minerals.local_to_map(local_pos)

		# Get the existing tile info at that cell
		var source_id = minerals.get_cell_source_id(tile_coords)
		var atlas_coords = minerals.get_cell_atlas_coords(tile_coords)

		# If it's the "fresh" ore tile, replace it with "depleted"
		if source_id == ORES_ID and atlas_coords == ORE1_POS:
			minerals.set_cell(tile_coords, ORES_ID, ORE1_DEPLETED_POS)
		if source_id == ORES_ID and atlas_coords == ORE2_POS:
			minerals.set_cell(tile_coords, ORES_ID, ORE2_DEPLETED_POS)
		if source_id == ORES_ID and atlas_coords == ORE3_POS:
			minerals.set_cell(tile_coords, ORES_ID, ORE3_DEPLETED_POS)
		if source_id == ORES_ID and atlas_coords == ORE4_POS:
			minerals.set_cell(tile_coords, ORES_ID, ORE4_DEPLETED_POS)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
