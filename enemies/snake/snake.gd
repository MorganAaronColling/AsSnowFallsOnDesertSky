extends "../EnemyBaseClass.gd"

func _on_hitbox_take_damage_signal(damage):
	on_take_damage_signal_received(damage)

func _on_animated_sprite_2d_animation_finished():
	on_animation_change_signal_received()

func _on_attack_area_area_entered(area):
	on_attack_area_entered_signal_received(area)

func _on_attack_radius_timer_area_entered(area):
	on_attack_radius_timer_area_enetered_signal_received(area)

func _on_attack_timer_timeout():
	on_attack_timer_timeout_signal_received()

func _on_animated_sprite_2d_animation_changed():
	if animationPlayer:
		$AnimatedSprite2DShadow.play(animationPlayer.animation)

func _on_death_timer_timeout():
	on_death_timer_timeout_signal_received()
