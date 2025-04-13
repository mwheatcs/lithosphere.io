class_name Inventory

extends ItemList

@export var inventory_size: int = 10
@export var placeholder_icon: Texture2D
@export var stats: Node;

var items: Array = [];

func update_stats_ui(change_money: int) -> void:
	stats.get_child(0).change_count(change_money)
	stats.get_child(1).set_count(items.size())
	

func _ready() -> void:
	for i in range(1, inventory_size+1):
		add_item(str(i), placeholder_icon)
		var temp_item = Item.new()
		temp_item.icon = placeholder_icon
		temp_item.count = i
		temp_item.price = i
		items.append(temp_item)
	
	update_stats_ui(0)


func get_item(index: int):
	return items[index]


func add_item_to_inventory(item: Item):
	var item_in_inventory: bool = false
	for i in inventory_size:
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
	
	update_stats_ui(0)


func remove_item_from_inventory(item: Item):
	var remove_index: int = -1
	for i in inventory_size:
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
