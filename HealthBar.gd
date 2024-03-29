extends AnimatedSprite2D

func _on_animation_finished():
	if animation == 'break':
		play("broken")
