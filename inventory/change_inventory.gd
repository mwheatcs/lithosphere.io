extends Button

@export var inventory: Inventory;

var default_text: String = "Sell";
var sell_price: int = 0;
var curr_item_index: int = -1;

func _on_inventory_item_selected(_index: int) -> void:
	show()
	curr_item_index = inventory.get_selected_items()[0];
	if curr_item_index != -1:
		sell_price = inventory.get_item(curr_item_index).get_sell_price()
		text = "Sell for " + str(sell_price)
	else:
		hide()
		sell_price = 0

func _on_inventory_focus_exited() -> void:
	inventory.deselect_all()

# sell item
func _on_pressed() -> void:
	if curr_item_index != -1:
		inventory.remove_item_index_from_inventory(curr_item_index)
		inventory.update_stats_ui(sell_price)
		curr_item_index = -1
		hide()
