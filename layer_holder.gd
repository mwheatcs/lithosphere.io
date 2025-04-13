extends Node2D

@onready var minerals: TileMapLayer = $Minerals

const MAP_WIDTH = 69
const MAP_HEIGHT = 37
const ORES_ID = 2
const ORE1_POS = Vector2i(4,14)
const ORE2_POS = Vector2i(4,15)
const ORE3_POS = Vector2i(4,16)
const ORE4_POS = Vector2i(4,17)
const STONE_POS = Vector2i(17,13)

func _ready() -> void:
	for i in range(20):
		var rand_x = randi() % MAP_WIDTH +1
		var rand_y = randi() % MAP_HEIGHT +1
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, ORE1_POS)
	for i in range(15):
		var rand_x = randi() % MAP_WIDTH +1
		var rand_y = randi() % MAP_HEIGHT +1
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, ORE2_POS)
	for i in range(10):
		var rand_x = randi() % MAP_WIDTH +1
		var rand_y = randi() % MAP_HEIGHT +1
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, ORE3_POS)
	for i in range(5):
		var rand_x = randi() % MAP_WIDTH +1
		var rand_y = randi() % MAP_HEIGHT +1
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, ORE4_POS)
	for i in range(50):
		var rand_x = randi() % MAP_WIDTH + 1
		var rand_y = randi() % MAP_HEIGHT + 1 
		minerals.set_cell(Vector2i(rand_x, rand_y), ORES_ID, STONE_POS)
		

func _process(delta: float) -> void:
	pass
