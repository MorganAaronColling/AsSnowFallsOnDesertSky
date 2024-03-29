extends RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween().set_loops()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.5)
	tween.tween_interval(0.1)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.5)
	tween.tween_interval(0.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

