extends CharacterBody2D

@export var speed := 100.0
@export var rotation_speed := 8.0  # How fast the unit rotates to face direction
@export var rotation_threshold := 0.1  # How closely unit must face the direction before moving
@export var visibility_radius := 200.0  # How far this unit can see (for fog of war)
@export var obstacle_avoidance_range := 50.0  # How far to look for obstacles
@export var unit_buffer_distance := 30.0  # Minimum distance to maintain from other units
@export var avoidance_weight := 0.6  # How strongly avoidance affects steering

var selected := false
var target := Vector2.ZERO
var has_target := false
var is_turning := false  # Track if we're still turning to face target

# Visual indicator for selection
var selection_indicator

# Add avoidance-related properties
var avoidance_vector := Vector2.ZERO  # Current avoidance direction

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
		
		# Calculate avoidance vectors before movement
		avoidance_vector = calculate_avoidance()
		
		# Blend direction with avoidance
		var desired_direction = direction
		if avoidance_vector.length() > 0.01:
			desired_direction = (direction + avoidance_vector * avoidance_weight).normalized()
			
		# Calculate the angle the unit should face
		var target_angle = desired_direction.angle() + PI/2
		
		# Smoothly rotate toward the target angle
		var angle_diff = wrapf(target_angle - rotation, -PI, PI)
		
		if abs(angle_diff) > 0.01:
			rotation += angle_diff * min(rotation_speed * delta, 1.0)
			is_turning = abs(angle_diff) > rotation_threshold
		else:
			is_turning = false
		
		# Only move if we're properly facing the direction
		if not is_turning:
			velocity = desired_direction * speed  # Use the blended direction
			move_and_slide()
		else:
			# Stop moving while turning
			velocity = Vector2.ZERO
	
	# Force redraw when path changes or when turning
	if (has_target and selected) or is_turning:
		queue_redraw()

# Calculate avoidance vector from nearby obstacles and units
func calculate_avoidance() -> Vector2:
	var avoidance = Vector2.ZERO
	var space_state = get_world_2d().direct_space_state
	
	# Parameters for raycasting to find obstacles
	var query_params = PhysicsRayQueryParameters2D.new()
	query_params.from = global_position
	query_params.exclude = [self]  # Don't detect self
	
	# Check in 8 directions for obstacles
	for angle in range(0, 360, 45):
		var direction = Vector2.RIGHT.rotated(deg_to_rad(angle))
		query_params.to = global_position + direction * obstacle_avoidance_range
		
		# Cast the ray
		var result = space_state.intersect_ray(query_params)
		if result:
			var distance = global_position.distance_to(result.position)
			
			# Calculate avoidance strength - stronger when closer
			var avoidance_strength = 1.0 - min(distance / obstacle_avoidance_range, 1.0)
			
			# Add avoidance in opposite direction of hit
			avoidance -= direction * avoidance_strength * avoidance_strength  # Square for stronger close avoidance
	
	# Specifically check for nearby units for extra avoidance
	var units = get_tree().get_nodes_in_group("units")
	for unit in units:
		if unit == self:
			continue  # Skip self
		
		var distance = global_position.distance_to(unit.global_position)
		if distance < unit_buffer_distance:
			# Calculate direction away from other unit
			var away_dir = (global_position - unit.global_position).normalized()
			
			# Stronger avoidance when closer to other unit
			var avoidance_strength = (1.0 - distance / unit_buffer_distance) * 1.5  # Higher weight for unit-unit avoidance
			avoidance += away_dir * avoidance_strength
	
	# Normalize the avoidance vector if it's significant
	if avoidance.length_squared() > 0.01:
		avoidance = avoidance.normalized()
	
	return avoidance

func _draw():
	# Only draw collision outline when selected
	if selected:
		draw_collision_outline()
		
		# Draw a path line showing where unit is going
		if has_target:
			draw_path_to_target()
		
		# Draw avoidance vector for debugging
		if avoidance_vector.length_squared() > 0.01:
			var avoidance_color = Color(1.0, 0.0, 0.0, 0.7)  # Red
			draw_line(Vector2.ZERO, avoidance_vector * 20.0, avoidance_color, 1.5)
			draw_circle(avoidance_vector * 20.0, 2.0, avoidance_color)
		
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
