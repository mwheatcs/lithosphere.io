extends Camera2D

var speed: float = 200.0  # pixels per second

func _process(delta: float) -> void:
	var input_vector = Vector2.ZERO
	# Replace the input action names with ones from your Input Map
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		position += input_vector * speed * delta
