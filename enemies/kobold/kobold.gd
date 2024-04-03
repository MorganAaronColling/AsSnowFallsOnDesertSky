extends "../EnemyBaseClass.gd"

func update_paths():
	animationPlayer = $SpritePivot/AnimatedSprite2D
	base_speed = 60
	attack_damage = 20
	base_acceleration = 120
	health = 30
	attack_offset = 35
	base_friction = base_acceleration / base_speed

func set_facing_direction() -> void:
	if player.global_position.x > global_position.x:
		facing_Left = true
		$SpritePivot.scale.x = -1
		attackAreaPivot.scale.x = -1
	elif player.global_position.x < global_position.x:
		facing_Left = false
		$SpritePivot.scale.x = 1
		attackAreaPivot.scale.x = 1

func _on_hitbox_take_damage_signal(damage):
	on_take_damage_signal_received(damage)

func _on_animated_sprite_2d_animation_finished():
	on_animation_change_signal_received()

func _on_attack_area_area_entered(area):
	if area.is_in_group('Player') and state != DEAD:
		attacking = true
		animationPlayer.play('attack')

func _on_attack_radius_timer_area_entered(area):
	on_attack_radius_timer_area_enetered_signal_received(area)

func _on_attack_timer_timeout():
	on_attack_timer_timeout_signal_received()
	
func deal_damage():
	if animationPlayer.animation == 'attack':
		if animationPlayer.frame == 2:
			for area in attackArea.get_overlapping_areas():
				if area.is_in_group('Player'):
					area.take_damage(attack_damage)	
		else:
			pass
	
func _on_animated_sprite_2d_animation_changed():
	if animationPlayer:
		$SpritePivot/AnimatedSprite2DShadow.play(animationPlayer.animation)


func _on_death_timer_timeout():
	on_death_timer_timeout_signal_received()
