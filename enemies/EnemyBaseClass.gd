extends CharacterBody2D

# VARS
var player
var randomnum
var randompos

# ANIMATION STATES
var attacking = false
var hurting = false

# STATS
var base_speed = 20
var base_acceleration: float = 50
var health = 15
var attack_damage = 5
var attack_offset = 10
var base_friction = base_acceleration / base_speed
var speed
var acceleration
var friction
var steering = Vector2.ZERO
var radius
var facing_Left = true

# ENUM
enum {
	SURROUND,
	ATTACK,
	SLEEPING,
	DEAD
}

# STATEssss
var state = SLEEPING

# NODES

@onready var IdleParticles = $IdleParticles
@onready var animationPlayer = $AnimatedSprite2D
@onready var attackAreaPivot = $AttackAreaPivot
@onready var attackArea = $AttackAreaPivot/AttackArea
@onready var attackRadiusTimer = $AttackRadiusTimer
@onready var attackTimer = $AttackTimer
@onready var collisionShape = $CollisionShape2D

func _ready():
	player = get_node('../Player')
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	randomnum = rng.randf_range(-1, 1)
	randompos = rng.randi_range(0, 1)
	update_paths()
	speed = base_speed
	acceleration = base_acceleration
	friction = base_friction
	radius = randf_range(45,90)
	$RayCast2D.add_exception(player)
	
func _physics_process(delta):
	match state:
		SURROUND:
			IdleParticles.emitting = false
			if hurting:
				pass
			else:
				move(get_circle_position(randomnum), delta)
		ATTACK:
			deal_damage()
			IdleParticles.emitting = false
			if attacking:
				pass
			elif hurting:
				pass
			else:
				if facing_Left:
					move(Vector2(player.global_position.x - attack_offset, player.global_position.y), delta)
				else:
					move(Vector2(player.global_position.x + attack_offset, player.global_position.y), delta)
		SLEEPING:
			IdleParticles.emitting = true
		DEAD:
			IdleParticles.emitting = false
			pass
	if state != DEAD and state != SLEEPING:
		apply_friction(delta)
		set_facing_direction()

func update_paths():
	pass
	
func apply_friction(delta: float) -> void:
	velocity -= velocity * friction * delta
	
func set_facing_direction() -> void:
	if player.global_position.x > global_position.x:
		facing_Left = true
		animationPlayer.flip_h = true
		attackAreaPivot.scale.x = -1
		$AnimatedSprite2DShadow.scale.x = -0.55
	elif player.global_position.x < global_position.x:
		facing_Left = false
		animationPlayer.flip_h = false
		attackAreaPivot.scale.x = 1
		$AnimatedSprite2DShadow.scale.x = 0.55

func move(target, delta):
	animationPlayer.play('run')
	var direction = (target - global_position).normalized() 
	velocity += direction * acceleration * delta
	avoid_obstacles()
	move_and_slide()
	
func get_circle_position(random):
	var kill_circle_centre = player.global_position
	 #Distance from center to circumference of circle
	var angle = (randompos * PI) + (randomnum * (PI / 4));
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return Vector2(x, y)

func on_attack_timer_timeout_signal_received():
	if state != DEAD:
		state = ATTACK
		attackRadiusTimer.monitoring = false
		attackArea.monitoring = true
	
func on_attack_radius_timer_area_enetered_signal_received(area):
	if area.is_in_group('Player') and state != DEAD:
		attackTimer.wait_time = randf_range(2, 3)
		attackTimer.start()
		if state == SLEEPING:
			state = SURROUND
		
func on_attack_area_entered_signal_received(area):
	if area.is_in_group('Player') and state != DEAD:
		attacking = true
		animationPlayer.play('attack')
		area.take_damage(attack_damage)
		reset_stats()
		
func on_animation_change_signal_received():
	if animationPlayer.animation == 'attack':
		hurting = false
		attacking = false
		attackArea.monitoring = false
		state = SURROUND
		attackRadiusTimer.monitoring = true
	elif animationPlayer.animation == 'hurt':
		hurting = false
		attacking = false
		attackArea.monitoring = false
		state = SURROUND
		attackRadiusTimer.monitoring = true
		
func on_take_damage_signal_received(damage):
	hurting = true
	health -= damage
	if health <= 0 && state != DEAD:
		state = DEAD
		collisionShape.set_deferred('disabled', true)
		animationPlayer.play('death')
		attackRadiusTimer.set_deferred('monitoring', false)
		attackArea.set_deferred('monitoring', false)
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(0, 0, 0, 0), 5)
	elif health >=0:
		animationPlayer.play('hurt')
		
func deal_damage():
	pass
	
func update_stats_when_attacking():
	speed = speed * 2
	acceleration = acceleration * 2
	friction = acceleration / speed
	
func reset_stats():
	speed = base_speed
	acceleration = base_acceleration
	friction = base_friction
	
func avoid_obstacles():
	var rayCast = $RayCast2D
	# Iterate through 8 directions (adjust angles for your needs)
	for angle in [0, PI/4, PI/2, 3*PI/4, PI, 5*PI/4, 3*PI/2, 7*PI/4]:
		# Cast ray in the direction
		rayCast.target_position = Vector2.from_angle(angle) * 30
		rayCast.force_raycast_update()
		# Check for collision
		if rayCast.is_colliding():
			# Obstacle detected, adjust velocity to avoid
			velocity = (velocity + Vector2.from_angle(angle).orthogonal()).normalized() * velocity.length()
			break  # Only consider closest obstacle
			
func on_death_timer_timeout_signal_received():
	queue_free()
	
