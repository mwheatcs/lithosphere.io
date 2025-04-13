extends Node2D
var factory_scene : PackedScene = preload("res://entities/Buildings/factory.tscn")
var money : int = 100  # Example starting money
var is_placing_factory: bool = false
var factory_preview: Node2D = null   # will hold our preview instance
@onready var money_display = get_node("/root/World/Display/CanvasLayer/VBoxContainer/CounterDisplay/Stats/Money")

func _input(event: InputEvent) -> void:
	if is_placing_factory:
		if event is InputEventMouseMotion:
			# Update the preview’s position to the current mouse global position.
			factory_preview.global_position = get_global_mouse_position()
		elif event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			# Finalize placement:
			# Optionally remove transparency
			if factory_preview.has_method("set_modulate"):
				factory_preview.modulate = Color(1, 1, 1, 1)
			# Optionally, you could snap the position to a grid:
			# factory_preview.position = snap_to_grid(get_global_mouse_position())
			
			# Exit placement mode:
			is_placing_factory = false
			factory_preview = null  # You can keep it in your scene as the final instance
			
			print("Factory placed at position: ", get_global_mouse_position())


func _on_display_buy_factory() -> void:
	var factory_cost = 10
	if money_display.count >= factory_cost:
		money_display.change_count(-factory_cost)
		# Enter placement mode:
		is_placing_factory = true
		
		factory_preview = factory_scene.instantiate()
		factory_preview.scale = Vector2(0.15, 0.15)
		if factory_preview.has_method("set_modulate"):
				factory_preview.modulate = Color(1, 1, 1, 0.5)
		add_child(factory_preview)
		print("Placement mode enabled. Click to place factory.")
	else:
		print("Not enough money to buy a factory!")
		_show_no_money_message()
		
		
func _show_no_money_message() -> void:
	# Create a Label node to display the message
	var msg = Label.new()
	msg.text = "Not enough money to buy a factory!"
	# Position it where you want in screen coordinates
	# Here we position it relative to the UI; adjust as needed.
	msg.anchor_left = 0.5
	msg.anchor_top = 0.1
	msg.anchor_right = 0.5
	msg.anchor_bottom = 0.1
	msg.position = Vector2(-150, 0)  # Offset from the anchor (left)
	msg.custom_minimum_size = Vector2(300, 30)

	# Add it to a CanvasLayer that is always on top, or to the UI node
	var ui_layer = get_node("/root/World/Display/CanvasLayer")
	ui_layer.add_child(msg)
	
	# Create a Timer node to remove the message after 2 seconds.
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 2.0
	ui_layer.add_child(timer)
	timer.timeout.connect(msg.queue_free)
	timer.start()
