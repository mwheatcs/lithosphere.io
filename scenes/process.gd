extends Button

@export var inventory: Inventory;

var default_text: String = "Process into ingot";
var curr_item_index: int = -1;

func display():
	var factories = get_tree().get_nodes_in_group("factory")
	if factories.size() > 0:
		var item_index_array = inventory.get_selected_items()
		if item_index_array.size() > 0:
			curr_item_index = item_index_array[0];
			if inventory.get_item(curr_item_index).Name.ends_with("ingot"):
				hide()
			else:
				show()
		else:
			curr_item_index = -1
			hide()
	else:
		hide()

func _on_inventory_item_selected(_index: int) -> void:
	display()

# process item
func _on_pressed() -> void:
	if curr_item_index != -1:
		# search for all factories
		var factories = get_tree().get_nodes_in_group("factory")
		if factories.size() > 0:
			for factory in factories:
				if factory.is_available():
					var original = inventory.get_item(curr_item_index)
					var item_copy = Item.new()
					item_copy.Name = original.Name
					item_copy.count = original.count
					item_copy.icon = original.icon
					item_copy.price = original.price
					factory.add_to_processing_queue(item_copy)
					inventory.remove_item_index_from_inventory(curr_item_index)
					break
		curr_item_index = -1
		hide()


func _on_inventory_focus_exited() -> void:
	inventory.deselect_all()


func _on_sell_pressed() -> void:
	curr_item_index = -1
	hide()
