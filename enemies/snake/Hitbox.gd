extends Area2D

signal take_damage_signal(damage: int)

func take_damage(damage):
	take_damage_signal.emit(damage)
