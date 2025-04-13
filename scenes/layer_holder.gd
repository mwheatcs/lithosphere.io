extends Node2D

@onready var minerals: TileMapLayer = $Minerals
@onready var world_manager = get_node("/root/World")


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

const MINING_RANGE = 100.0
const CELL_SIZE = Vector2(16, 16) 

# Mineral highlighting variables
var hovered_mineral_coords: Vector2i = Vector2i(-1, -1)  # Invalid default position
var hovered_mineral_pos: Vector2
var is_mineral_hovered: bool = false
var highlight = null  # For drawing the highlight

func _ready() -> void:
	# Create a node for drawing the mineral highlight
	highlight = Node2D.new()
	highlight.z_index = 10  # Ensure it draws above the minerals
	add_child(highlight)
	highlight.set_script(load("res://scenes/mineral_highlight.gd"))  # We'll create this script
	
	# Connect to draw signal
	highlight.connect("draw", _on_highlight_draw)
	
	# Existing mineral spawning code
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
		

# # This function is called on any input event (mouse, keyboard, etc.)
# func _input(event: InputEvent) -> void:
# 	# Check for a left-mouse click
# 	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
# 		# Get the mouse position in world coordinates
# 		var mouse_pos = get_global_mouse_position()

# 		# Convert that to the tilemap's local space
# 		var local_pos = minerals.to_local(mouse_pos)	
# 		# Convert local space to tile coordinates
# 		var tile_coords = minerals.local_to_map(local_pos)

# 		# Get the existing tile info at that cell
# 		var source_id = minerals.get_cell_source_id(tile_coords)
# 		var atlas_coords = minerals.get_cell_atlas_coords(tile_coords)

# 		if source_id == ORES_ID:
# 		# Check if any selected unit is close enough to mine the ore
# 			if can_any_selected_unit_mine(tile_coords):
# 				# Replace the tile with its depleted version, depending on which ore it is
# 				if atlas_coords == ORE1_POS:
# 					minerals.set_cell(tile_coords, ORES_ID, ORE1_DEPLETED_POS)
# 				elif atlas_coords == ORE2_POS:
# 					minerals.set_cell(tile_coords, ORES_ID, ORE2_DEPLETED_POS)
# 				elif atlas_coords == ORE3_POS:
# 					minerals.set_cell(tile_coords, ORES_ID, ORE3_DEPLETED_POS)
# 				elif atlas_coords == ORE4_POS:
# 					minerals.set_cell(tile_coords, ORES_ID, ORE4_DEPLETED_POS)
# 			else:
# 				print("No selected unit is close enough to mine this ore.")

func can_any_selected_unit_mine(tile_coords: Vector2i) -> bool:
	var tile_local_center = Vector2(tile_coords) * CELL_SIZE + (CELL_SIZE * 0.5)
	var tile_world_pos = minerals.global_transform * tile_local_center


	# Loop through each selected unit from the selection manager (world node)
	for unit in world_manager.selected_units:
		if unit.global_position.distance_to(tile_world_pos) <= MINING_RANGE:
			return true
	return false

# Check if mouse is hovering over a mineral when units are selected
func check_mineral_hover() -> void:
	is_mineral_hovered = false
	var mouse_pos = get_global_mouse_position()
	var local_pos = minerals.to_local(mouse_pos)
	var tile_coords = minerals.local_to_map(local_pos)
	
	# Check if there's a mineral at the mouse position
	var source_id = minerals.get_cell_source_id(tile_coords)
	var atlas_coords = minerals.get_cell_atlas_coords(tile_coords)
	
	# Reset hover state
	hovered_mineral_coords = Vector2i(-1, -1)
	
	# Check if we're hovering over a mineral and units are selected
	if source_id == ORES_ID and world_manager.selected_units.size() > 0:
		# Check if it's an actual mineral (not depleted)
		if atlas_coords == ORE1_POS or atlas_coords == ORE2_POS or atlas_coords == ORE3_POS or atlas_coords == ORE4_POS:
			hovered_mineral_coords = tile_coords
			hovered_mineral_pos = get_mineral_world_position(tile_coords)
			is_mineral_hovered = true
			
			# If right mouse button is pressed, inform units this is a mining target
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
				for unit in world_manager.selected_units:
					unit.set_mining_target(hovered_mineral_pos, tile_coords)

# Get the world position of a mineral tile (center of the tile)
func get_mineral_world_position(tile_coords: Vector2i) -> Vector2:
	var tile_local_center = Vector2(tile_coords) * CELL_SIZE + (CELL_SIZE * 0.5)
	var tile_world_pos = minerals.global_transform * tile_local_center
	return tile_world_pos

# Draw the mineral highlight
func _on_highlight_draw() -> void:
	if is_mineral_hovered:
			# Get the tileset and source
			var tileset = minerals.tile_set
			if not tileset:
				return
			
			# Get the source ID and atlas coords of the hovered mineral
			var source_id = minerals.get_cell_source_id(hovered_mineral_coords)
			var atlas_coords = minerals.get_cell_atlas_coords(hovered_mineral_coords)
			
			if source_id < 0:
				return
				
			# Get the tileset source
			var source = tileset.get_source(source_id) as TileSetAtlasSource
			if not source:
				return
				
			# Get the tile data
			var tile_data = source.get_tile_data(atlas_coords, 0)
			if not tile_data:
				return
				
			# Get the texture region for the specific tile
			var texture_region = source.get_tile_texture_region(atlas_coords, 0)
			
			# Calculate world position for the highlight
			var pos = minerals.map_to_local(hovered_mineral_coords)
			var world_pos = minerals.to_global(pos)
			var highlight_pos = highlight.to_local(world_pos)
			
			# Calculate offset to center the highlight
			var offset = Vector2(-texture_region.size.x/2, -texture_region.size.y/2)
			
			# Draw highlight outline following the sprite shape
			draw_sprite_outline(highlight_pos + offset, texture_region.size, Color(1.0, 1.0, 0.0, 0.8), 2.0)

# Draw an outline around a sprite shape
func draw_sprite_outline(pos: Vector2, size: Vector2, color: Color, thickness: float) -> void:
	# Draw a diamond-like shape that better represents a tile sprite than a rectangle
	var points = [
		pos + Vector2(size.x * 0.5, 0),              # Top middle
		pos + Vector2(size.x, size.y * 0.5),         # Right middle
		pos + Vector2(size.x * 0.5, size.y),         # Bottom middle
		pos + Vector2(0, size.y * 0.5)               # Left middle
	]
	
	# Connect the points to form the outline
	highlight.draw_line(points[0], points[1], color, thickness)
	highlight.draw_line(points[1], points[2], color, thickness)
	highlight.draw_line(points[2], points[3], color, thickness)
	highlight.draw_line(points[3], points[0], color, thickness)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	check_mineral_hover()
	highlight.queue_redraw()
	pass

# Deplete a mineral at the given coordinates
func deplete_mineral(tile_coords: Vector2i) -> void:
	# Get the existing tile info at that cell
	var source_id = minerals.get_cell_source_id(tile_coords)
	var atlas_coords = minerals.get_cell_atlas_coords(tile_coords)
	
	if source_id == ORES_ID:
		# Replace the tile with its depleted version, depending on which ore it is
		if atlas_coords == ORE1_POS:
			minerals.set_cell(tile_coords, ORES_ID, ORE1_DEPLETED_POS)
			print("Ore type 1 depleted at: ", tile_coords)
		elif atlas_coords == ORE2_POS:
			minerals.set_cell(tile_coords, ORES_ID, ORE2_DEPLETED_POS)
			print("Ore type 2 depleted at: ", tile_coords)
		elif atlas_coords == ORE3_POS:
			minerals.set_cell(tile_coords, ORES_ID, ORE3_DEPLETED_POS)
			print("Ore type 3 depleted at: ", tile_coords)
		elif atlas_coords == ORE4_POS:
			minerals.set_cell(tile_coords, ORES_ID, ORE4_DEPLETED_POS)
			print("Ore type 4 depleted at: ", tile_coords)
