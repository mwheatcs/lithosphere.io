extends Control

@onready var panel   = $CanvasLayer/Panel
@onready var label1  = $CanvasLayer/Panel/Label1
@onready var label2  = $CanvasLayer/Panel/Label2
@onready var label3  = $CanvasLayer/Panel/Label3
@onready var button  = $CanvasLayer/Panel/Button


func _ready() -> void:
	# Ensure the second label starts hidden.
	label2.visible = false


func _on_button_pressed() -> void:
	if label1.visible:
		label1.hide()
		label2.show()
	elif label2.visible:
		label2.hide()
		label3.show()
	else:
		queue_free()
