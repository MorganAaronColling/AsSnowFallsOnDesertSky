extends TextureRect

func _on_main_scene_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0, 0, 0), 0.5)
