extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(255, 255, 255, 0), 0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
