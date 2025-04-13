class_name Inventory

extends ItemList

@export var inventory_size: int = 20
@export var placeholder_icon: Texture2D

var items: Array = [Item];

func _ready() -> void:
	for i in inventory_size:
		add_item(str(i), placeholder_icon)
		var temp_item = Item.new()
		temp_item.icon = placeholder_icon
		temp_item.count = i
		items.append(temp_item)


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


func remove_item_index_from_inventory(index: int):
	items.remove_at(index)
	remove_item(index)
	
