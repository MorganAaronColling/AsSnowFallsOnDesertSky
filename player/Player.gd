extends CharacterBody2D

var speed: float = 200
var acceleration: float = 2000
var friction: float = acceleration / speed
var health: int
var max_health: int = 50

var normal_friction = acceleration / speed
var high_friction = 5
var slide_friction = 3

var normal_acceleration = 2000
var low_acceleration = 50

var sliding = false
var sword_drawn = false
var sword_drawing = false
var attacking = false
var hurting = false
var dead = false

var basic_attack_damage = 10
var water_tiles_list = [Vector2i(20, 12), Vector2i(20, 13), Vector2i(20, 14), Vector2i(21, 12), Vector2i(21, 13), Vector2i(21, 14), Vector2i(22, 12), Vector2i(22, 13), Vector2i(22, 14)]

@onready var tilemap: TileMap = get_node('../../World')
@onready var playerPortrait: AnimatedSprite2D = get_node('../../GUICanvas/GUI/PlayerPortrait')
@onready var playerPortraitBlood: AnimatedSprite2D = get_node('../../GUICanvas/GUI/DamageEffect')
@onready var GUI: Control = get_node('../../GUICanvas/GUI')
@onready var camera: Camera2D = get_node('../../PlayerCamera')
@onready var healthBarProgress: TextureProgressBar = get_node('../../GUICanvas/GUI/HealthProgressBar')
@onready var playerPortraitGlass: AnimatedSprite2D = get_node('../../GUICanvas/GUI/PortraitGlass')
@onready var playerHealthBar: AnimatedSprite2D = get_node('../../GUICanvas/GUI/HealthBar')
@onready var playerHealthBarBreakEffect: AnimatedSprite2D = get_node('../../GUICanvas/GUI/HealthBarBreakEffect')
@onready var playerDeathScene: TextureRect = get_node('../../PlayerDeathScene')
@onready var game: Node2D = get_node("/root/game")
@onready var playerHealthLabel: Label = get_node('../../GUICanvas/GUI/HealthLabel')
@onready var playerHealthBarBackground: TextureProgressBar = get_node('../../GUICanvas/GUI/HealthProgressBarBackground')


func _ready():
	health = max_health
	healthBarProgress.max_value = max_health
	playerHealthBarBackground.max_value = max_health
	healthBarProgress.value = health
	playerHealthBarBackground.value = health
	playerHealthLabel.text = str(health) + '/' + str(max_health)

func _process(delta: float) -> void:
	if !dead:
		apply_traction(delta)
		apply_friction(delta)
		input_controller()

func _physics_process(delt: float) -> void:
	move_and_slide()
	state_management()
	set_facing_direction()
	
func apply_traction(delta: float) -> void:
	var traction = Input.get_vector("left","right","up","down")
	velocity += traction * acceleration * delta
	
func apply_friction(delta: float) -> void:
	velocity -= velocity * friction * delta
	
func state_management():
	if sliding:
		var tileBelow = tilemap.local_to_map(position)
		var tileType = tilemap.get_cell_atlas_coords(0, tileBelow)
		if water_tiles_list.has(tileType):
			$WaterSplash.emitting = true
		if velocity.length() < 18:
			finish_slide()
	elif sword_drawing:
		pass
	elif attacking:
		deal_damage()
	elif hurting:
		pass
	elif dead:
		pass
	else:
		running_animation_controller()
	
func running_animation_controller() -> void:
	if velocity.length() > 15:
		$AnimatedSprite2D.play('run')
		var tileBelow = tilemap.local_to_map(position)
		var tileType = tilemap.get_cell_atlas_coords(0, tileBelow)
		if water_tiles_list.has(tileType):
			$WaterSplash.emitting = true
			if $Footstep.playing:
				$Footstep.stop()
			if !$WaterSplashAudio.playing:
				$WaterSplashAudio.play()
		else:
			$WaterSplash.emitting = false
			$WaterSplashAudio.stop()
			if !$Footstep.playing:
				$Footstep.play()
	else:
		$WaterSplash.emitting = false
		if !sword_drawn:
			$AnimatedSprite2D.play('idle')
		else:
			$AnimatedSprite2D.play('idleSword')
		if $Footstep.playing:
			$Footstep.stop()
		if $WaterSplashAudio.playing:
			$WaterSplashAudio.stop()
		
func set_facing_direction() -> void:
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$AttackAreaPivot.scale.x = 1
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$AttackAreaPivot.scale.x = -1
		
func start_slide() -> void:
	$AnimatedSprite2D.play('slide')
	if $Footstep.playing:
		$Footstep.stop()
	if $WaterSplashAudio.playing:
		$WaterSplashAudio.stop()
	$Slide.play(2.7)
	sliding = true
	acceleration = low_acceleration
	friction = slide_friction
	
func finish_slide() -> void:
	sliding = false
	acceleration = normal_acceleration
	friction = normal_friction
	
func input_controller() -> void:
	if !attacking and !sword_drawing and !sliding and !hurting:
		if Input.is_action_just_pressed("slide") && velocity.length() > 100:
			start_slide()
		elif Input.is_action_just_pressed('basicAttack'):
			acceleration = low_acceleration
			friction = high_friction
			$Footstep.stop()
			$WaterSplashAudio.stop()
			if sword_drawn:
				attacking = true
				$AnimatedSprite2D.play('attackBasic')
			else: 
				sword_drawn = true
				sword_drawing = true
				$AnimatedSprite2D.play('drawSword')
		elif Input.is_action_just_pressed('heavyAttack'):
			acceleration = low_acceleration
			friction = high_friction
			$Footstep.stop()
			$WaterSplashAudio.stop()
			if sword_drawn:
				attacking = true
				$AnimatedSprite2D.play('attackHeavy')
			else: 
				sword_drawn = true
				sword_drawing = true
				$AnimatedSprite2D.play('drawSword')
		elif Input.is_action_just_pressed('holsterToggle'):
			$Footstep.stop()
			$WaterSplashAudio.stop()
			acceleration = low_acceleration
			friction = high_friction
			if sword_drawn:
				sword_drawn = false
				sword_drawing = true
				$AnimatedSprite2D.play('holsterSword')
			else:
				sword_drawn = true
				sword_drawing = true
				$AnimatedSprite2D.play('drawSword')
				
func deal_damage():
	if $AnimatedSprite2D.animation == 'attackBasic' or $AnimatedSprite2D.animation == 'attackHeavy':
		if $AnimatedSprite2D.frame == 2:
			$AttackAreaPivot/BasicAttackArea.monitoring = true
			$SwordSwingBasic.play()
		elif $AnimatedSprite2D.frame == 8:
			$AttackAreaPivot/SecondaryAttackArea.monitoring = true
			$SwordSwingSecondary.play()
		elif $AnimatedSprite2D.frame == 13:
			$AttackAreaPivot/SpinAttackArea.monitoring = true
			$SwordSwingSpin.play()
		else:
			$AttackAreaPivot/BasicAttackArea.monitoring = false
			$AttackAreaPivot/SecondaryAttackArea.monitoring = false
			$AttackAreaPivot/SpinAttackArea.monitoring = false
			
			
func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == 'holsterSword' or $AnimatedSprite2D.animation == 'drawSword':
		sword_drawing = false
		acceleration = normal_acceleration
		friction = normal_friction
	elif $AnimatedSprite2D.animation == 'attackBasic' or $AnimatedSprite2D.animation == 'attackHeavy':
		attacking = false
		acceleration = normal_acceleration
		friction = normal_friction
	elif $AnimatedSprite2D.animation == 'hurt':
		hurting = false
		acceleration = normal_acceleration
		friction = normal_friction
		
		
func _on_basic_attack_area_area_entered(area):
	if area.is_in_group('targetable'):
		area.take_damage(basic_attack_damage)

func _on_secondary_attack_area_area_entered(area):
	if area.is_in_group('targetable'):
		area.take_damage(basic_attack_damage)

func _on_spin_attack_area_area_entered(area):
	if area.is_in_group('targetable'):
		area.take_damage(basic_attack_damage)

func _on_player_hitbox_player_take_damage(damage):
	if !hurting and !sliding and !dead:
		player_hit(damage)
		if health <= 0:
			player_death()
		else:
			player_hurt()
			screen_shake_on_hit()

func _on_animated_sprite_2d_animation_changed():
	if playerPortrait:
		playerPortrait.play($AnimatedSprite2D.animation)
		
func screen_shake_on_hit():
	var tween = create_tween()
	tween.tween_property(GUI, "position", Vector2(5, 5), 0.1)
	tween.tween_interval(0.1)
	tween.tween_property(GUI, "position", Vector2(-5, -5), 0.1)
	tween.tween_interval(0.1)
	tween.tween_property(GUI, "position", Vector2(0, 0), 0.1)
	tween.tween_interval(0.1)
	camera.add_trauma(1)

func player_death():
	dead = true
	$AnimatedSprite2D.play('death')
	playerPortraitBlood.play('death')
	playerPortraitGlass.play('break')
	playerHealthBar.play('break')
	playerHealthBarBreakEffect.play('break')
	$DeathSound.play()
	z_index = 1
	playerDeathScene.play_death_animation()
	camera.play_death_animation()
	game.player_death()
	
func player_hit(damage):
		acceleration = low_acceleration
		friction = high_friction
		hurting = true
		attacking = false
		sliding = false
		sword_drawing = false
		health -= damage
		healthBarProgress.value = health
		playerHealthLabel.text = str(health) + '/' + str(max_health)
		var tween = create_tween()
		tween.tween_property(playerHealthBarBackground, "value", health, 0.6)

		
func player_hurt():
	playerPortraitBlood.play('damage')
	$AnimatedSprite2D.play('hurt')
	$HurtSound.play()
	$Footstep.stop()
	$WaterSplashAudio.stop()
	
	
