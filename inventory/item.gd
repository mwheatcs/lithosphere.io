class_name Item

extends GDScript

var Name : String :
	get:
		return Name
	set(value):
		Name = value

var count : int :
	get:
		return count
	set(value):
		count = value
		
func get_count() -> int:
	return count

var icon : Texture2D :
	get:
		return icon
	set(value):
		icon = value;

var price : int :
	get:
		return price
	set(value):
		price = value
		

func get_sell_price():
	return price * count
	
static func get_ore_atlas_texture(tile_coords: Vector2i, tile_size: Vector2, tileset_path: String) -> AtlasTexture:
	var tileset_texture: Texture2D = load(tileset_path)
	var atlas_tex = AtlasTexture.new()
	atlas_tex.atlas = tileset_texture
	# Calculate the region: Multiply tile_coords by tile_size to get the top-left pixel,
	# then use tile_size as the region size.
	atlas_tex.region = Rect2(Vector2(tile_coords) * tile_size, tile_size)
	return atlas_tex
