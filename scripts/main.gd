extends Node2D

signal scene_out

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('enter'):
		scene_out.emit()
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://gameScenes/game.tscn")
