extends CharacterBody2D

@export var speed := 100.0
@export var rotation_speed := 8.0  # How fast the unit rotates to face direction
@export var rotation_threshold := 0.1  # How closely unit must face the direction before moving
@export var visibility_radius := 200.0  # How far this unit can see (for fog of war)
var selected := false
var target := Vector2.ZERO
var has_target := false
var is_turning := false  # Track if we're still turning to face target

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
	# Only process if we have a target
	if has_target:
		var direction = (target - global_position).normalized()
		
		# Check if we've reached the target (within a small threshold)
		if global_position.distance_to(target) < 5.0:
			has_target = false
			is_turning = false
			return
			
		# Calculate the angle the unit should face
		# Add PI/2 (90 degrees) so that the initial down direction is "forward"
		var target_angle = direction.angle() + PI/2
		
		# Smoothly rotate toward the target angle
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		
		if abs(angle_diff) > 0.01:  # Small threshold to prevent jitter
			rotation += angle_diff * min(rotation_speed * delta, 1.0)
			is_turning = abs(angle_diff) > rotation_threshold
		else:
			is_turning = false
		
		# Only move if we're properly facing the direction
		if not is_turning:
			velocity = direction * speed
			move_and_slide()
		else:
			# Stop moving while turning
			velocity = Vector2.ZERO
	
	# Force redraw when path changes or when turning
	if (has_target and selected) or is_turning:
		queue_redraw()

func _draw():
	# Only draw collision outline when selected
	if selected:
		draw_collision_outline()
		
		# Draw a path line showing where unit is going
		if has_target:
			draw_path_to_target()
		
		# Only draw selection indicator if we have no external highlight node
		if not has_node("SelectionHighlight"):
			# Get the appropriate size for the highlight based on the sprite
			var size = get_appropriate_highlight_size()
			

# Draws an outline around the unit's actual collision polygon, respecting transforms
func draw_collision_outline():
	var outline_color = Color(0, 0, 1, 1)
	var line_thickness = 2.0
	
	# Get the collision polygon node
	var collision_polygon = get_node("CollisionPolygon2D")
	
	# Check if it exists and has valid polygon data
	if collision_polygon and collision_polygon is CollisionPolygon2D and not collision_polygon.polygon.is_empty():
		var points = collision_polygon.polygon
		
		 # Since _draw is in local coordinates, we need to convert from global to local
		# Get the global transform of the CollisionPolygon2D and our local transform
		var polygon_global_transform = collision_polygon.get_global_transform()
		var local_transform = get_global_transform().affine_inverse()
		
		# Draw the collision outline with proper transform handling
		for i in range(points.size()):
			# Convert points to global space then back to our local drawing space
			var global_start = polygon_global_transform * points[i]
			var global_end = polygon_global_transform * points[(i + 1) % points.size()]
			
			# Convert global points to our local space for drawing
			var start_pos = local_transform * global_start
			var end_pos = local_transform * global_end
			
			draw_line(start_pos, end_pos, outline_color, line_thickness)

# Draws a green line showing unit's path to target
func draw_path_to_target():
	if has_target:
		var line_color = Color(0.0, 0.8, 0.0, 0.8)  # Bright green with slight transparency
		var line_thickness = 1.5
		
		# Convert target from global to local coordinates
		var target_local = to_local(target)
		
		# Draw line from unit to target
		draw_line(Vector2.ZERO, target_local, line_color, line_thickness)
		
		# Draw a small circle at the target location
		var target_radius = 3.0
		draw_circle(target_local, target_radius, Color(0.0, 1.0, 0.0, 1.0))

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
	is_turning = true  # Start by turning to face target
	queue_redraw()  # Force redraw to show the path line
