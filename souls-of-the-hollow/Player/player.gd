class_name Player
extends CharacterBody2D

# Finite state machine
enum PlayerStates {MOVE, ATTACK, DEAD, DASH} # Array padrao, 0, 1, 2, 3 , HURT, DEAD 
var CurrentState = PlayerStates.MOVE # Estado atual do personagem

@export var damage_node: PackedScene

var normalSpeed = 150.0
@export var SPEED = 150.0
const JUMP_VELOCITY = -400.0
var _direction: float = 0.0
var _double_jump: bool = false
var isAttacking: bool = false
var invertAttackCollision: int = -32
var double_damage_taken: bool = false
var have_demon_sword: bool = false
var in_defense: bool = false
var recent_defense: bool = false
var parry: bool = false
var is_burning: bool = false
var flipped: bool = false

const dashspeed = 300.0
const dashlength = 0.4

@onready var dash = $Dash

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _player_health_bar: ProgressBar

func _ready():
	$AttackCollision/CollisionShape2D.disabled = true
	randomize()
	setup()
	
func setup():
	have_demon_sword = false
	$PlayerHitBox/CollisionShape2D.disabled = false
	scale.x = 1
	_direction = 0.1
	var times = game_controller.times_finished
	if times:
		var multiplier = 0.02 * times
		game_controller.player_health += (game_controller.player_health * multiplier)
		game_controller.player_damage += (game_controller.player_damage * multiplier)
		game_controller.player_max_health += (game_controller.player_max_health * multiplier)
	
func recalculate_damage():
	var times_finished = game_controller.times_finished
	
	if have_demon_sword:
		if times_finished:
			var multiplier = 0.02 * times_finished
			game_controller.player_damage += (game_controller.base_demon_sword_damage * multiplier)
		else:
			game_controller.player_damage += game_controller.base_demon_sword_damage
	else:
		if times_finished:
			var multiplier = 0.02 * times_finished
			game_controller.player_damage += (game_controller.player_damage * multiplier)


func set_player_health_bar(player_health_bar: ProgressBar):
	_player_health_bar = player_health_bar

func popup(message: String):
	var instantiate_damagedamage = damage_node.instantiate()
	instantiate_damage.get_child(0).text = message
	instantiate_damage.position = global_position
	var tween = get_tree().create_tween()
	tween.tween_property(instantiate_damage, "position", global_position + _get_direction(), 0.75)
	get_tree().current_scene.add_child(instantiate_damage)

func _get_direction():
	return Vector2(randf_range(-1, 1), -randf()) * 16
	
func dash_collision_logic(logic: bool):
	self.set_collision_layer_value(1, logic)
	self.set_collision_mask_value(1, logic)
	$PlayerHitBox/CollisionShape2D.disabled = !logic
	
func set_health_label():
	var vidaAtual: float = float(game_controller.player_health)/float(game_controller.player_max_health) * 100
	_player_health_bar.value = vidaAtual
	
func _physics_process(delta):
	set_health_label()
	# Adiciona a gravidade ao jogo
	velocity.y += gravity * delta
	
	
	if Input.is_action_just_pressed("dash"):
		dash_collision_logic(false)
		CurrentState = PlayerStates.DASH
		dash.start_dash(dashlength)
		
	SPEED = dashspeed if dash.is_dashing() else normalSpeed
	
	if Input.is_action_just_pressed("die"):
		game_controller.player_health = 0
		
	if Input.is_action_just_pressed("ui_end"):
		position = Vector2(2228, 140) 
		
	if Input.is_action_just_pressed("hard"):
		game_controller.times_finished += 1
		
	if Input.is_action_just_pressed("easy"):
		game_controller.times_finished -= 1
		
		
	if Input.is_action_just_pressed("defense") and not isAttacking:
		parry = true
		in_defense = true
		await get_tree().create_timer(0.1).timeout
		parry = false
	elif Input.is_action_pressed("defense") and not isAttacking:
		in_defense = true
	elif Input.is_action_just_released("defense"):
		in_defense = false
	
	if game_controller.player_health <= 0:
		Die()
		return
		
	Move()
	animatePlayer()
	move_and_slide()
	
# Esquerda -1
# cima -1
func animatePlayer():
	if CurrentState == PlayerStates.MOVE:
		if not isAttacking and not in_defense:
			if is_on_floor():
				if velocity.x == 0.0:
					$AnimationPlayer.play("Idle")
				elif not dash.is_dashing():
					$AnimationPlayer.play("Walk")
			else:
				if velocity.y < 0 or _double_jump and not dash.is_dashing():
					$AnimationPlayer.play("Jump")
				if velocity.y > 10 and not dash.is_dashing():
					$AnimationPlayer.play("Fall")
		elif is_on_floor() and in_defense:
			$AnimationPlayer.play("Defense")
		else:
			$AnimationPlayer.play("Attack")
	if CurrentState == PlayerStates.DASH and dash.is_dashing():
		$AnimationPlayer.play("Dash")
	
	if _direction > 0.0 and flipped:
		scale.x = -scale.x
		flipped = false
	elif _direction < 0.0 and not flipped:
		scale.x = -scale.x
		flipped = true
	
func CheckAndExecuteAttack():
	if Input.is_action_pressed("Attack") and not CurrentState == PlayerStates.DASH:
		isAttacking = true

func CheckAndExecuteJump():
	if is_on_floor():
		_double_jump = false
	# Handle Jump.
	if Input.is_action_just_pressed("ui_up") and (is_on_floor() or not _double_jump):
		velocity.y = JUMP_VELOCITY
		if not is_on_floor():
			_double_jump = true

func CheckAndExecuteWalk():
	var input := Input.get_axis("ui_left", "ui_right")
	if input:
		velocity.x = input * SPEED
		_direction = input
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func Move():
	CheckAndExecuteWalk()
	CheckAndExecuteJump()
	CheckAndExecuteAttack()

func Die():
	$AnimationPlayer.play("Die")

func restart_game():
	game_controller.actual_stage=1
	game_controller.change_stage(load("res://Maps/01/map_01.tscn"))
	game_controller.reset_player()

func onStateFinish():
	CurrentState = PlayerStates.MOVE

func _on_finished_attack_animation():
	isAttacking = false

func _on_animated_sprite_2d_animation_finished():
	$AttackCollision/CollisionShape2D.disabled = true
	isAttacking = false

func _on_hitbox_area_entered(area: Area2D):
	if area.get_parent().is_in_group("enemies") and area.get_groups().size() > 0:
		if parry:
			game_controller.get_camera().shake_camera(3, 0.3)
			$AnimationTela.play("Parry")
			return
		var enemyDamage = game_controller.enemies_damage[area.get_groups()[0]]
		if in_defense:
			enemyDamage/=2
		if double_damage_taken:
			enemyDamage *=2
		game_controller.player_health -= enemyDamage
		game_controller.get_camera().shake_camera(3, 0.3)
		popup(str(enemyDamage))
		if area.get_groups()[0] == "fireSkeletonAttack" or area.get_groups()[0] == "demonAttack":
			popup("INCENDIADO!!")
			is_burning = true
			burn_player()

func burn_player():
	var i = 0
	while i <= 10 and is_burning:
		game_controller.player_health -= 2
		game_controller.get_camera().shake_camera(3, 0.3)
		popup(str(2))
		await get_tree().create_timer(2).timeout
		i+=2
		if i == 10:
			is_burning = false
	is_burning = false

func _parry():
	parry = !parry
	if recent_defense:
		recent_defense = false
		

func _on_player_hit_box_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body.name == "MagmaTileMap":
		game_controller.player_health -= 5
		game_controller.get_camera().shake_camera(3, 0.3)
		popup("INCENDIADO!!")
		burn_player()
