extends Area2D

signal snake_take_damage(damage: int)

func take_damage(damage):
	snake_take_damage.emit(damage)
