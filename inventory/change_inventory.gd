extends Button

@export var inventory: Inventory;

var curr_item_index: int = -1;

func _on_inventory_item_selected(_index: int) -> void:
	show()
	curr_item_index = inventory.get_selected_items()[0];

func _on_inventory_focus_exited() -> void:
	inventory.deselect_all()

# sell item
func _on_pressed() -> void:
	await get_tree().process_frame
	if curr_item_index != -1:
		inventory.remove_item_index_from_inventory(curr_item_index)
