class_name Inventory

extends ItemList

@export var placeholder_icon: Texture2D
@export var stats: Node;

var items: Array = [];

func update_inventory_ui():
		if items.size() == 0:
			hide()
		else:
			show()

func update_stats_ui(change_money: int) -> void:
	stats.get_child(0).change_count(change_money)
	stats.get_child(1).set_count(items.size())
	update_inventory_ui()


func _ready() -> void:
	# TODO remove placeholders and add diff mineral item types
	#var ore_coords = [
		#Vector2i(4, 14),  # Ore type 1
		#Vector2i(4, 15),  # Ore type 2
		#Vector2i(4, 16),  # Ore type 3
		#Vector2i(4, 17)   # Ore type 4
	#]
	#var tile_size = Vector2(16, 16)  
	#var tileset_path = "res://assets/TileSetNature.png"
#
	#for i in range(1, inventory_size+1):
		#var ore_index = (i - 1) % ore_coords.size()
		#var ore_atlas_coords = ore_coords[ore_index]
		#var icon = Item.get_ore_atlas_texture(ore_atlas_coords, tile_size, tileset_path)
		#add_item(str(i), icon)
		#var temp_item = Item.new()
		#temp_item.icon = icon
		#temp_item.count = i
		#temp_item.price = i
		#items.append(temp_item)
	
	update_stats_ui(0)


func get_item(index: int):
	if items.size() > 0:
		return items[index]


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
