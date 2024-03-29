extends ParallaxBackground

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CloudsSlow.motion_offset.x += 5 * delta
	$CloudsFast.motion_offset.x += 10 * delta
	
