extends Button

var main_scene = preload("res://scenes/World.tscn").instantiate()

func _on_pressed() -> void:
	get_tree().root.add_child(main_scene)
