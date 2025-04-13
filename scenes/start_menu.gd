extends Control

var main_scene = preload("res://scenes/World.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)


func _on_exit_pressed() -> void:
	get_tree().quit()
