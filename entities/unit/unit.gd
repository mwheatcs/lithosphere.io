extends CharacterBody2D

@export var speed := 100.0
var selected := false
var target := Vector2.ZERO
var has_target := false

# Visual indicator for selection
var selection_indicator

func _ready():
	# Create a selection indicator (circle around unit when selected)
	selection_indicator = Node2D.new()
	add_child(selection_indicator)
	# Set it to not show initially
	selection_indicator.visible = false
	
	# Add this unit to the "units" group so it can be found easily
	add_to_group("units")

func _process(delta):
	# Only move if we have a target
	if has_target:
		var direction = (target - global_position).normalized()
		
		# Check if we've reached the target (within a small threshold)
		if global_position.distance_to(target) < 5.0:
			has_target = false
		else:
			velocity = direction * speed
			move_and_slide()
	
func _draw():
	# Only draw collision outline when selected
	if selected:
		draw_collision_outline()
		
		# Only draw selection indicator if we have no external highlight node
		if not has_node("SelectionHighlight"):
			# Get the appropriate size for the highlight based on the sprite
			var size = get_appropriate_highlight_size()
			
			# Draw a diamond-shaped selection indicator instead of an arc
			var diamond_points = [
				Vector2(0, -size),   # Top
				Vector2(size, 0),    # Right
				Vector2(0, size),    # Bottom
				Vector2(-size, 0)    # Left
			]
			# Draw diamond outline
			for i in range(diamond_points.size()):
				draw_line(
					diamond_points[i], 
					diamond_points[(i + 1) % diamond_points.size()], 
					Color(0.9, 0.9, 0.2, 0.7), 
					1.5
				)

# Draws a yellow outline around the unit's actual collision polygon
func draw_collision_outline():
	var outline_color = Color(1.0, 1.0, 0.0, 1.0)  # Bright yellow
	var line_thickness = 1.0
	
	# Get the collision polygon node (assuming it's named "UnitCollisionPolygon" - adjust name as needed)
	var collision_polygon = get_node("UnitCollisionPolygon")
	
	# Check if it exists and has valid polygon data
	if collision_polygon and collision_polygon is CollisionPolygon2D and not collision_polygon.polygon.is_empty():
		var points = collision_polygon.polygon
		
		# Draw the actual collision outline without scaling
		for i in range(points.size()):
			var start = points[i]
			var end = points[(i + 1) % points.size()]  # Wrap around to first point
			draw_line(start, end, outline_color, line_thickness)

# Helper function to get the appropriate highlight size based on sprite or collision shape
func get_appropriate_highlight_size():
	var size = 20  # Default fallback size
	
	# First priority: Check for Sprite2D or AnimatedSprite2D
	if has_node("Sprite2D"):
		var sprite = get_node("Sprite2D")
		if sprite.texture:
			var sprite_size = sprite.texture.get_size()
			var scaled_size = max(sprite_size.x, sprite_size.y) * sprite.scale.x / 2.0
			return scaled_size * 1.1  # Add 10% margin
	elif has_node("AnimatedSprite2D"):
		var sprite = get_node("AnimatedSprite2D")
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(sprite.animation):
			var frame = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
			if frame:
				var sprite_size = frame.get_size()
				var scaled_size = max(sprite_size.x, sprite_size.y) * sprite.scale.x / 2.0
				return scaled_size * 1.1  # Add 10% margin
	
	# Second priority: Check collision shape if sprite not found
	if has_node("CollisionPolygon2D"):
		var collision_polygon = get_node("CollisionPolygon2D")
		if collision_polygon and not collision_polygon.polygon.is_empty():
			# Calculate the furthest point from center
			var max_distance = 0.0
			for point in collision_polygon.polygon:
				var distance = point.length()
				if distance > max_distance:
					max_distance = distance
			return max_distance * 1.1  # Add 10% margin
	
	# Check for CircleShape2D as well
	if has_node("CollisionShape2D"):
		var collision_shape = get_node("CollisionShape2D")
		if collision_shape and collision_shape.shape:
			if collision_shape.shape is CircleShape2D:
				return collision_shape.shape.radius * 1.1
			elif collision_shape.shape is RectangleShape2D:
				return max(collision_shape.shape.extents.x, collision_shape.shape.extents.y) * 1.1
	
	return size  # Return default if nothing else found

# Called when unit is selected
func select():
	selected = true
	queue_redraw() # Redraw to show selection circle

# Called when unit is deselected
func unselect():
	selected = false
	queue_redraw() # Redraw to remove selection circle

# Sets a new target location for the unit to move to
func set_target(pos):
	target = pos
	has_target = true
