extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	play(randf_range(0, 41))

