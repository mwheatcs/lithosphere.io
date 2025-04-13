extends TextureRect

func zoom(seconds: float) -> void:
	# Create a new tween
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	# Tween the scale property from current to target over time
	tween.tween_property(self, "scale", Vector2(3.5, 3.5), seconds)
