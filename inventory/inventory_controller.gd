class_name Inventory

extends ItemList

@export var placeholder_icon: Texture2D
@export var stats: Node;

signal update_sell_price

var items: Array = [];

func update_inventory_ui():
		if items.size() == 0:
			hide()
		else:
			show()

func update_stats_ui(change_money: int) -> void:
	stats.get_child(0).change_count(change_money)
	var total_count = 0
	for item in items:
		total_count += item.count
	stats.get_child(1).set_count(total_count)
	update_inventory_ui()


func _ready() -> void:
	update_stats_ui(0)


func get_item(index: int) -> Item:
	if items.size() > 0:
		return items[index]
	return null


func add_item_to_inventory(item: Item):
	var item_in_inventory: bool = false
	for i in items.size():
		if items[i] == null:
			continue
		if item.Name == items[i].Name:
			items[i].count += item.count
			set_item_text(i, str(item.count))
			set_item_icon(i, item.icon)
			item_in_inventory = true
			
	if not item_in_inventory:
		items.append(item)
		add_item(str(item.count), item.icon)
	
	update_sell_price.emit()
	update_stats_ui(0)



func remove_item_from_inventory(item: Item):
	var remove_index: int = -1
	for i in items.size():
		if items[i] == null:
			continue
		if item.Name == items[i].Name:
			items[i].count = 0
			remove_index = i
			
	if remove_index != -1:
		items.remove_at(remove_index)
		remove_item(remove_index)
	
	update_stats_ui(0)



func remove_item_index_from_inventory(index: int):
	if index < items.size() and index >= 0:
		items.remove_at(index)
		remove_item(index)
		update_stats_ui(0)
