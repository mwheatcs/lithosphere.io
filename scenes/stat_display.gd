class_name StatDisplay

extends Control

@export var texture: Texture2D;
@export var Name: String;
@export var count: int :
	get:
		return count
	set(value):
		count = value

var texture_button = TextureButton.new()
var name_label = Label.new()
var count_label = Label.new()

func _ready() -> void:
	texture_button.texture_normal = texture
	name_label.text = Name + ":"
	count_label.text = str(count)
	add_child(texture_button)
	add_child(name_label)
	add_child(count_label)

func set_count(new_count: int):
	count = new_count
	count_label.text = str(count)

func change_count(change: int):
	count += change
	count_label.text = str(count)
