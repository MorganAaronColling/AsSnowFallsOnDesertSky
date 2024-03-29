extends ParallaxBackground


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CloudLonely.motion_offset.x += delta * 3
	$Cloud1.motion_offset.x += delta * 15
	$Cloud2.motion_offset.x += delta * 10
	$Cloud3.motion_offset.x += delta * 5
	$CloudsBackground.motion_offset.x += delta * 5
	
