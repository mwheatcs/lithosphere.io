extends StaticBody2D

var processing_rate: int = 1; # processing rate per 1 ore
var processing_queue: Array = [];

@onready var available = true
@onready var inventory = get_node("/root/World/Display/CanvasLayer/VBoxContainer/CounterDisplay/Inventory")
@export var placeholder: Texture2D;

const INGOT_ID = 3
var ingot_coords = [
	Vector2i(1, 4),
	Vector2i(6, 4),
	Vector2i(7, 4),
	Vector2i(8, 4)
]
var tile_size = Vector2(32, 32);
var tileset_path = "res://assets/items-orescrystalsingots-transparent.png"

func is_available() -> bool:
	return available

func add_to_processing_queue(item):
	processing_queue.append(item)
	process_into_ingot()

func set_ingot_icon(ingot, i):
	var ingot_index = (i - 1) % ingot_coords.size()
	var ingot_atlas_coords = ingot_coords[ingot_index]
	ingot.icon = Item.get_ore_atlas_texture(ingot_atlas_coords, tile_size, tileset_path)

func convert_into_ingot(ore: Item) -> Item:
	var ingot = Item.new()
	ingot.Name = ore.Name + " ingot"
	ingot.count = 1
	ingot.price = ore.price * 2
	
	# set appropriate ingot icon based on ore name
	if ore.Name.contains("1"):
		set_ingot_icon(ingot, 1)
	elif ore.Name.contains("2"):
		set_ingot_icon(ingot, 2)
	elif ore.Name.contains("3"):
		set_ingot_icon(ingot, 3)
	elif ore.Name.contains("4"):
		set_ingot_icon(ingot, 4)
	
	return ingot

func process_into_ingot() -> bool:
	if processing_queue.size() > 0 and available:
		available = false
		var current_item = processing_queue.pop_front()
		for i in range(current_item.get_count()):
			await get_tree().create_timer(processing_rate).timeout
			inventory.add_item_to_inventory(convert_into_ingot(current_item))
		available = true
		return true
	available = true
	return false
