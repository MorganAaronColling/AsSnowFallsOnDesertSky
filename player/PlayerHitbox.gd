extends Area2D

signal player_take_damage(damage: int)

func take_damage(damage):
	player_take_damage.emit(damage)
	
