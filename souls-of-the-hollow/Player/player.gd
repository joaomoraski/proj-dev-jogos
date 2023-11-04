class_name Player
extends CharacterBody2D

# Finite state machine
enum PlayerStates {MOVE, ATTACK, DEAD} # Array padrao, 0, 1, 2, 3 , HURT, DEAD 
var CurrentState = PlayerStates.MOVE # Estado atual do personagem

@export var damage_node: PackedScene

var normalSpeed = 150.0
@export var SPEED = 150.0
const JUMP_VELOCITY = -400.0
var _direction: float = 0.1
var _double_jump: bool = false
var isAttacking: bool = false
var invertAttackCollision: int = -32

const BASE_HEALTH = 100
const BASE_DAMAGE = 25

const dashspeed = 300.0
const dashlength = 0.4

@onready var dash = $Dash

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func setup():
	game_controller.setup_player(BASE_HEALTH, BASE_DAMAGE)

func _ready():
	$AttackCollision/CollisionShape2D.disabled = true
	randomize()

func popup(message: String):
	var damage = damage_node.instantiate()
	damage.get_child(0).text = message
	damage.position = global_position
	var tween = get_tree().create_tween()
	tween.tween_property(damage, "position", global_position + _get_direction(), 0.75)
	get_tree().current_scene.add_child(damage)

func _get_direction():
	return Vector2(randf_range(-1, 1), -randf()) * 16
	
func dash_collision_logic(logic: bool):
	self.set_collision_layer_value(1, logic)
	self.set_collision_mask_value(1, logic)
	$Hitbox/CollisionShape2D.disabled = !logic
	
func _physics_process(delta):
	# Adiciona a gravidade ao jogo
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("dash"):
		dash_collision_logic(false)
		dash.start_dash(dashlength)
		
	SPEED = dashspeed if dash.is_dashing() else normalSpeed
	
	if Input.is_action_just_pressed("die"):
		game_controller.player_life = 0
		
	if Input.is_action_just_pressed("ui_end"):
		position = Vector2(1163, 113) 
		
	if Input.is_action_just_pressed("hard"):
		game_controller.times_finished += 1
		
	if Input.is_action_just_pressed("easy"):
		game_controller.times_finished -= 1
		
	if game_controller.player_life <= 0:
		Die()
		return
		
	Move()
	animatePlayer()
	move_and_slide()
	
# Esquerda -1
# cima -1
func animatePlayer():
	if not isAttacking:
		if is_on_floor():
			if velocity.x == 0.0:
				$AnimatedSprite2D.play("Idle")
			elif not dash.is_dashing():
				$AnimatedSprite2D.play("Walk")
		else:
			if velocity.y < 0 or _double_jump and not dash.is_dashing():
				$AnimatedSprite2D.play("Jump")
			if velocity.y > 10 and not dash.is_dashing():
				$AnimatedSprite2D.play("Fall")
	else:
		$AnimatedSprite2D.play("Attack")
		
	
	if dash.is_dashing():
		$AnimatedSprite2D.play("Dash")
	
	$AnimatedSprite2D.flip_h = false if _direction > 0.0 else true
	$AttackCollision/CollisionShape2D.position = Vector2(0,2) if _direction > 0 else Vector2(invertAttackCollision,2)
	
func CheckAndExecuteAttack():
	if Input.is_action_just_pressed("Attack"):
		$AttackCollision/CollisionShape2D.disabled = false
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
	$AnimatedSprite2D.play("Die")
	await $AnimatedSprite2D.animation_finished
	get_tree().reload_current_scene()
	game_controller.setup_player(BASE_HEALTH, BASE_DAMAGE)

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Attack":
		$AttackCollision/CollisionShape2D.disabled = true
		isAttacking = false

func _on_hitbox_body_entered(body):
	if body.is_in_group("enemies"):
		game_controller.player_life -= game_controller.enemies_damage["Slime"]
		game_controller.get_camera().shake_camera(3, 0.3)
		popup(str(game_controller.enemies_damage["Slime"]))
