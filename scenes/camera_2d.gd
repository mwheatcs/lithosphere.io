extends Camera2D

var speed: float = 200.0  # pixels per secon
# Define the bounds (in world space) the camera is allwowed to move
@export var min_bound: Vector2 = Vector2(-36, -13)
@export var max_bound: Vector2 = Vector2(520, 300)

func _process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	# Replace the input action names with ones from your Input Map
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		position += input_vector * speed * delta
	position.x = clamp(position.x, min_bound.x, max_bound.x)
	position.y = clamp(position.y, min_bound.y, max_bound.y)
