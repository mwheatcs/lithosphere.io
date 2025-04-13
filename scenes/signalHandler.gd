extends Control

signal buy_factory
func _on_buy_factory_pressed() -> void:
	buy_factory.emit()
