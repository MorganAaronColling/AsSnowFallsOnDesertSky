extends TextureRect

@export var speed: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	texture.diffuse_texture.noise.offset.x -= delta * speed
