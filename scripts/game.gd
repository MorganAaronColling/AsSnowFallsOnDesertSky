extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func player_death():
	$GameMusic.stop()
	$WindBackground.stop()
	$DeathAmbience.play()
