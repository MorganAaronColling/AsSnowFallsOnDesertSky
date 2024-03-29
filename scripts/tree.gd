extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(randf_range(0, 5)).timeout
	$AnimatedSprite2D.play('idle')


func _on_hit_box_take_damage_signal():
	$TreeDamageEffect.emitting = true
	
func _on_hitbox_take_damage_signal():
	$TreeDamageEffect.emitting = true
