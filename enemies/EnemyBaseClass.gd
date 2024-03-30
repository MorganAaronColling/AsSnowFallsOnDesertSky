extends CharacterBody2D

# VARS
var player
var randomnum

# ANIMATION STATES
var attacking = false
var hurting = false

# STATS
var speed = 15
var health = 15
var attack_damage = 5

# ENUM
enum {
	SURROUND,
	ATTACK,
	SLEEPING,
	DEAD
}

# STATE
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
	update_paths()
	
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
				move(player.global_position, delta)
		SLEEPING:
			IdleParticles.emitting = true
		DEAD:
			IdleParticles.emitting = false
			pass
	set_facing_direction()

func update_paths():
	pass
	
func set_facing_direction() -> void:
	if velocity.x > 0:
		animationPlayer.flip_h = true
		attackAreaPivot.scale.x = -1
	elif velocity.x < 0:
		animationPlayer.flip_h = false
		attackAreaPivot.scale.x = 1

func move(target, delta):
	animationPlayer.play('run')
	var direction = (target - global_position).normalized() 
	var desired_velocity =  direction * speed
	var steering = (desired_velocity - velocity) * delta * 2.5
	velocity += steering
	move_and_slide()
	
func get_circle_position(random):
	var kill_circle_centre = player.global_position
	var radius = 60
	 #Distance from center to circumference of circle
	var angle = (randi_range(0, 1) * PI) + (randomnum * (PI / 4));
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
		
func on_animation_change_signal_received():
	if animationPlayer.animation == 'attack':
		attacking = false
		attackArea.monitoring = false
		state = SURROUND
		attackRadiusTimer.monitoring = true
	elif animationPlayer.animation == 'hurt':
		hurting = false
		
func on_take_damage_signal_received(damage):
	hurting = true
	health -= damage
	if health <= 0 && state != DEAD:
		state = DEAD
		collisionShape.disabled = true
		animationPlayer.play('death')
		attackRadiusTimer.set_deferred('monitoring', false)
		attackArea.set_deferred('monitoring', false)
	elif health >=0:
		animationPlayer.play('hurt')
		
func deal_damage():
	pass
	
