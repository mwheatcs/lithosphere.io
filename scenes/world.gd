extends Node2D

var drag_start_position = Vector2.ZERO
var is_dragging = false
var selected_units = []
var min_drag_distance = 5.0
var selection_layer: CanvasLayer
var selection_rect: Control

# Fog of War variables
var fog_layer: CanvasLayer
var fog_texture: ImageTexture
var fog_image: Image
var fog_sprite: Sprite2D
var fog_cell_size := 16  # Size of each fog cell in pixels
var fog_visible_color := Color(0, 0, 0, 0)  # Transparent (visible)
var fog_explored_color := Color(0.1, 0.1, 0.1, 0.7)  # Gray (explored but not visible)
var fog_unexplored_color := Color(0, 0, 0, 1.0)  # Pitch black (completely unexplored)
var map_size := Vector2i(2000, 2000)  # Size of the map in pixels
var resource_nodes := []  # Will store all resource nodes for fog of war visibility
var fog_state_map := {}  # Tracks the fog state of each cell (0=unexplored, 1=explored, 2=visible)

func _ready():
	# Set process_input to true to ensure input events are processed
	set_process_input(true)
	# Set process to true to ensure _process is called
	set_process(true)
	
	# Create a CanvasLayer for our selection rectangle to ensure it's drawn on top
	selection_layer = CanvasLayer.new()
	selection_layer.layer = 100  # Very high layer number to be on top
	add_child(selection_layer)
	
	# Create a Control node for drawing the selection rectangle
	selection_rect = Control.new()
	selection_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	selection_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE  # Don't block mouse events
	selection_layer.add_child(selection_rect)
	
	# Connect the draw signal for the selection rectangle
	selection_rect.connect("draw", _on_selection_rect_draw)
	
	# Initialize fog of war
	_setup_fog_of_war()
	
	# Find and store all resource nodes for fog of war handling
	_find_resource_nodes()

func _process(delta):
	# If dragging, update the selection rect
	if is_dragging:
		selection_rect.queue_redraw()
	
	# Update fog of war based on unit positions
	_update_fog_of_war()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start dragging
				drag_start_position = get_global_mouse_position()
				is_dragging = true
				print("Started dragging at: ", drag_start_position)
				
				# Deselect all units if not holding Shift
				if not Input.is_key_pressed(KEY_SHIFT):
					_deselect_all_units()
			else:
				# End dragging, perform selection
				if is_dragging:
					var end_position = get_global_mouse_position()
					print("Ended dragging at: ", end_position)
					_select_units_in_rectangle(drag_start_position, end_position)
					is_dragging = false
					# Force a redraw to clear the selection rectangle
					selection_rect.queue_redraw()

	# Handle right-click to command selected units to move
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_command_selected_units(get_global_mouse_position())

# This function is called when the selection_rect needs to be drawn
func _on_selection_rect_draw():
	# Only draw if currently dragging, otherwise leave blank
	if is_dragging:
		# Convert global mouse position to canvas coordinates
		var current_mouse_position = get_global_mouse_position()
		
		# Create selection rectangle in screen coordinates
		var rect = Rect2(
			min(drag_start_position.x, current_mouse_position.x),
			min(drag_start_position.y, current_mouse_position.y),
			abs(current_mouse_position.x - drag_start_position.x),
			abs(current_mouse_position.y - drag_start_position.y)
		)
		
		# Draw the selection rectangle
		selection_rect.draw_rect(rect, Color(1.0, 0.0, 0.0, 0.3), true)  # Red fill
		selection_rect.draw_rect(rect, Color(1.0, 1.0, 1.0, 1.0), false, 3.0)  # White border
		
		print("Drew selection box with dimensions: ", rect)
	# When not dragging, the function is still called but we don't draw anything
	# This effectively clears the rectangle

# Select all units within the given rectangle
func _select_units_in_rectangle(start_position, end_position):
	# Create a Rect2 from the start and end positions
	var rect = Rect2(
		min(start_position.x, end_position.x),
		min(start_position.y, end_position.y),
		abs(end_position.x - start_position.x),
		abs(end_position.y - start_position.y)
	)
	
	# Get all units in the scene
	var units = get_tree().get_nodes_in_group("units")
	
	# If holding Shift, add to selection without deselecting first
	var add_to_selection = Input.is_key_pressed(KEY_SHIFT)
	if not add_to_selection:
		_deselect_all_units()
	
	# Select all units within the rectangle
	for unit in units:
		if rect.has_point(unit.global_position):
			unit.select()
			if not selected_units.has(unit):
				selected_units.append(unit)

# Deselect all units
func _deselect_all_units():
	for unit in selected_units:
		if is_instance_valid(unit):  # Check if unit still exists
			unit.unselect()
	
	selected_units.clear()

# Command selected units to move to the target position
func _command_selected_units(target_position):
	# Skip if no units are selected
	if selected_units.size() == 0:
		return
		
	# Calculate staggered positions around the target
	var staggered_positions = _calculate_formation_positions(target_position, selected_units.size())
	
	# Assign each unit a unique position in the formation
	for i in range(selected_units.size()):
		var unit = selected_units[i]
		if is_instance_valid(unit):
			unit.set_target(staggered_positions[i])

# Calculate positions in a formation around a target point
func _calculate_formation_positions(center_position, unit_count):
	var positions = []
	var spacing = 40.0  # Increased spacing between units to prevent collisions
	
	# For a single unit, just use the target position
	if unit_count == 1:
		positions.append(center_position)
		return positions
	
	# For 2-8 units, arrange in a circle formation
	if unit_count <= 8:
		var radius = spacing + (unit_count * 5)  # Scale radius with unit count
		for i in range(unit_count):
			var angle = (2 * PI / unit_count) * i
			var offset = Vector2(cos(angle), sin(angle)) * radius
			positions.append(center_position + offset)
	# For larger groups, use a grid formation
	else:
		var cols = ceil(sqrt(unit_count))
		var rows = ceil(unit_count / float(cols))
		
		# Center the grid on the target position
		var grid_width = (cols - 1) * spacing
		var grid_height = (rows - 1) * spacing
		var start_x = center_position.x - grid_width/2
		var start_y = center_position.y - grid_height/2
		
		# Generate grid positions
		for i in range(unit_count):
			var row = floor(i / cols)
			var col = i % cols
			var pos = Vector2(
				start_x + (col * spacing),
				start_y + (row * spacing)
			)
			positions.append(pos)
			
	return positions

# Sets up the fog of war system
func _setup_fog_of_war():
	# Create a dedicated layer for fog of war
	fog_layer = CanvasLayer.new()
	fog_layer.layer = 50  # Below selection rectangle (100) but above game world
	add_child(fog_layer)
	
	# Calculate fog dimensions based on map size
	var fog_width := int(map_size.x / fog_cell_size) + 1
	var fog_height := int(map_size.y / fog_cell_size) + 1
	
	# Create an image for the fog
	fog_image = Image.create(fog_width, fog_height, false, Image.FORMAT_RGBA8)
	
	# Fill it with unexplored color initially
	fog_image.fill(fog_unexplored_color)
	
	# Create texture from image
	fog_texture = ImageTexture.create_from_image(fog_image)
	
	# Create sprite to display the fog
	fog_sprite = Sprite2D.new()
	fog_sprite.texture = fog_texture
	fog_sprite.centered = false
	fog_sprite.scale = Vector2(fog_cell_size, fog_cell_size)
	fog_sprite.position = Vector2.ZERO
	fog_layer.add_child(fog_sprite)
	
	# Initialize all cells as unexplored (fog_state = 0)
	for y in range(fog_image.get_height()):
		for x in range(fog_image.get_width()):
			fog_state_map[Vector2i(x, y)] = 0

# Find and store all resource nodes in the scene
func _find_resource_nodes():
	var potential_resources = get_tree().get_nodes_in_group("resources")
	if potential_resources.size() > 0:
		resource_nodes = potential_resources
	else:
		# If no "resources" group exists, look for typical resource node names
		for child in get_children():
			if "resource" in child.name.to_lower() or "mineral" in child.name.to_lower() or "crystal" in child.name.to_lower():
				resource_nodes.append(child)

# Update fog of war based on unit positions
func _update_fog_of_war():
	# First create a new fog image to work with
	var updated_fog = Image.create(fog_image.get_width(), fog_image.get_height(), false, Image.FORMAT_RGBA8)
	
	# Start by filling all cells with unexplored/explored status based on fog_state_map
	# This creates the default state for this frame: black for unexplored, gray for previously explored
	for y in range(updated_fog.get_height()):
		for x in range(updated_fog.get_width()):
			var cell_pos = Vector2i(x, y)
			var state = fog_state_map.get(cell_pos, 0)  # Default to unexplored (0)
			
			if state == 0:  # Unexplored
				updated_fog.set_pixel(x, y, fog_unexplored_color)  # Pitch black
			else:  # Explored (state >= 1)
				updated_fog.set_pixel(x, y, fog_explored_color)    # Gray
	
	# Track cells that are currently visible this frame
	var visible_cells = {}
	
	# Get all units and update visibility around them
	var units = get_tree().get_nodes_in_group("units")
	
	# For each unit, reveal the fog around it
	for unit in units:
		# Set visibility radius based on unit properties
		var vision_radius = 5  # Default in fog cells
		if unit.get("visibility_radius"):
			vision_radius = unit.visibility_radius / fog_cell_size
		
		# Convert unit position to fog grid coordinates
		var fog_pos = Vector2i(
			int(unit.global_position.x / fog_cell_size),
			int(unit.global_position.y / fog_cell_size)
		)
		
		# Clear fog around the unit (make it visible)
		for y in range(-vision_radius, vision_radius + 1):
			for x in range(-vision_radius, vision_radius + 1):
				var check_pos = fog_pos + Vector2i(x, y)
				
				# Check if position is within image bounds
				if check_pos.x >= 0 and check_pos.x < updated_fog.get_width() and \
				   check_pos.y >= 0 and check_pos.y < updated_fog.get_height():
					# Check if position is within vision radius (circular visibility)
					var distance = Vector2(x, y).length()
					if distance <= vision_radius:
						# Mark this cell as visible in this frame
						updated_fog.set_pixel(check_pos.x, check_pos.y, fog_visible_color)
						visible_cells[check_pos] = true
						
						# Also mark this cell as at least explored in the state map for future frames
						fog_state_map[check_pos] = max(fog_state_map.get(check_pos, 0), 1)
	
	# Handle resources - only make them visible in explored/visible areas
	for resource in resource_nodes:
		# Skip if resource doesn't have the visible_behind_fog property or it's false
		if not (resource.get("visible_behind_fog") and resource.visible_behind_fog):
			continue
			
		var resource_pos = Vector2i(
			int(resource.global_position.x / fog_cell_size),
			int(resource.global_position.y / fog_cell_size)
		)
		
		# Only make resources visible in explored areas, not in unexplored black fog
		if resource_pos in fog_state_map and fog_state_map[resource_pos] >= 1:
			# Resource is in explored territory - no need to do anything
			# It will already be either visible (transparent) or gray based on fog state
			pass
		else:
			# Resource is in unexplored territory - ensure it's hidden by black fog
			# (This should already be the case, but just to be sure)
			if 0 <= resource_pos.x < updated_fog.get_width() and \
			   0 <= resource_pos.y < updated_fog.get_height():
				updated_fog.set_pixel(resource_pos.x, resource_pos.y, fog_unexplored_color)
	
	# Update the fog image and texture
	fog_image = updated_fog
	fog_texture.update(fog_image)
