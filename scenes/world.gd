extends Node2D

# Selection variables
var selection_start = Vector2.ZERO
var selection_end = Vector2.ZERO
var is_dragging = false
var selected_units = []

# Visual style for selection box
var selection_color = Color(0.2, 0.8, 0.2, 0.2)
var selection_border_color = Color(0.2, 1.0, 0.2, 0.8)

func _ready():
	pass

func _process(delta):
	# Force redraw when dragging to update selection rectangle
	if is_dragging:
		queue_redraw()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Start selection drag
				selection_start = event.position
				selection_end = event.position
				is_dragging = true
				
				 # Check for direct unit click before starting drag
				var clicked_unit = get_unit_at_position(event.position)
				
				# If shift is not pressed, deselect all units
				if not Input.is_key_pressed(KEY_SHIFT):
					deselect_all_units()
				
				# If we clicked on a unit, select it
				if clicked_unit:
					select_unit(clicked_unit)
				
			else:
				# End selection drag
				is_dragging = false
				selection_end = event.position
				
				# Only process rectangle selection if we've actually dragged
				if selection_start.distance_to(selection_end) > 5:
					select_units_in_rectangle(selection_start, selection_end)
				
				# Reset drag variables
				queue_redraw()
				
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Move selected units to the clicked position
			if not selected_units.is_empty():
				move_selected_units_to(event.position)
				
	elif event is InputEventMouseMotion:
		# Update the end position of selection rectangle while dragging
		if is_dragging:
			selection_end = event.position

func _draw():
	# Draw selection rectangle while dragging
	if is_dragging:
		var rect = get_selection_rect()
		draw_rect(rect, selection_color)
		draw_rect(rect, selection_border_color, false, 2.0)

func get_selection_rect():
	# Create Rect2 from selection points
	var top_left = Vector2(
		min(selection_start.x, selection_end.x),
		min(selection_start.y, selection_end.y)
	)
	var bottom_right = Vector2(
		max(selection_start.x, selection_end.x),
		max(selection_start.y, selection_end.y)
	)
	return Rect2(top_left, bottom_right - top_left)

func select_units_in_rectangle(start_pos, end_pos):
	var rect = get_selection_rect()
	
	# Find all units in the scene
	var units = get_tree().get_nodes_in_group("units")
	
	for unit in units:
		# Check if unit is within selection rectangle
		if rect.has_point(unit.global_position):
			select_unit(unit)

func select_unit(unit):
	if not selected_units.has(unit):
		selected_units.append(unit)
		unit.select()

func deselect_unit(unit):
	selected_units.erase(unit)
	unit.unselect()

func deselect_all_units():
	for unit in selected_units:
		unit.unselect()
	selected_units.clear()

func move_selected_units_to(position):
	# Basic formation: send all units to the same spot
	# A more advanced implementation could arrange them in formation
	for unit in selected_units:
		unit.set_target(position)

# Get the unit at a specific position, if any
func get_unit_at_position(position):
	# Use physics to detect units at click position (more reliable than polygon check)
	var space_state = get_world_2d().direct_space_state
	
	# Set up physics query parameters
	var query = PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collision_mask = 1  # Adjust this to match your collision layers
	
	# Get all objects at that point
	var result = space_state.intersect_point(query)
	
	# Check if any of the colliding objects are units
	for collision in result:
		var collider = collision.collider
		if collider is CharacterBody2D and collider.is_in_group("units"):
			return collider
	
	# No unit found at position
	return null
