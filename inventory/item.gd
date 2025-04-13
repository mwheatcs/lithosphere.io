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

var icon : Texture2D :
	get:
		return icon
	set(value):
		icon = value;
