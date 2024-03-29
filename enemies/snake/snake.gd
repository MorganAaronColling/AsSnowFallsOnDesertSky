extends CharacterBody2D

var SPEED = 30
var player
var randomnum
var attacking = false
var hurting = false
var health = 20

var snake_damage = 10

enum {
	SURROUND,
	ATTACK,
	SLEEPING,
	DEAD
}

var state = SLEEPING

func _ready():
	player = get_node('../Player')
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf()
	
func _physics_process(delta):
	match state:
		SURROUND:
			$SnakeSleepParticles.emitting = false
			if hurting:
				pass
			else:
				move(get_circle_position(randomnum), delta)
		ATTACK:
			$SnakeSleepParticles.emitting = false
			if attacking:
				pass
			elif hurting:
				pass
			else:
				move(player.global_position, delta)
		SLEEPING:
			$SnakeSleepParticles.emitting = true
		DEAD:
			$SnakeSleepParticles.emitting = false
			pass
	set_facing_direction()
				
func set_facing_direction() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
		$AttackAreaPivot.scale.x = -1
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = false
		$AttackAreaPivot.scale.x = 1

func move(target, delta):
	$AnimatedSprite2D.play('chase')
	var direction = (target - global_position).normalized() 
	var desired_velocity =  direction * SPEED
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	move_and_slide()
	
func get_circle_position(random):
	var kill_circle_centre = player.global_position
	var radius = 50
	 #Distance from center to circumference of circle
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;

	return Vector2(x, y)

func _on_attack_timer_timeout():
	if state != DEAD:
		state = ATTACK
		$AttackRadiusTimer.monitoring = false
		$AttackAreaPivot/AttackArea.monitoring = true

func _on_attack_radius_timer_area_entered(area):
	if area.is_in_group('Player') and state != DEAD:
		$AttackTimer.wait_time = randf_range(2, 3)
		$AttackTimer.start()
		if state == SLEEPING:
			state = SURROUND

func _on_attack_area_area_entered(area):
	if area.is_in_group('Player') and state != DEAD:
		attacking = true
		$AnimatedSprite2D.play('attack')
		area.take_damage(snake_damage)
		
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == 'attack':
		attacking = false
		$AttackAreaPivot/AttackArea.monitoring = false
		state = SURROUND
		$AttackRadiusTimer.monitoring = true
	elif $AnimatedSprite2D.animation == 'hurt':
		hurting = false

func _on_hitbox_snake_snake_take_damage(damage):
	hurting = true
	health -= damage
	if health <= 0 && state != DEAD:
		state = DEAD
		$AnimatedSprite2D.play('death')
		$AttackRadiusTimer.monitoring = false
		$AttackAreaPivot/AttackArea.monitoring = false
	elif health >=0:
		$AnimatedSprite2D.play('hurt')
