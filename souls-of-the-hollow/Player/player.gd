class_name Player
extends CharacterBody2D

# Finite state machine
enum PlayerStates {MOVE, ATTACK} # Array padrao, 0, 1, 2, 3 , HURT, DEAD 
var CurrentState = PlayerStates.MOVE # Estado atual do personagem

@export var SPEED = 150.0
const JUMP_VELOCITY = -400.0
var damage: float = 10
var _direction: float = 0.1
var _double_jump: bool = false
var isAttacking: bool = false
var invertAttackCollision: int = -32

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	$AttackCollision/CollisionShape2D.disabled = true
	
func _physics_process(delta):
	# Adiciona a gravidade ao jogo
	velocity.y += gravity * delta
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
			else:
				$AnimatedSprite2D.play("Walk")
		else:
			if velocity.y < 0 or _double_jump:
				$AnimatedSprite2D.play("Jump")
			if velocity.y > 10:
				$AnimatedSprite2D.play("Fall")
	else:
		$AnimatedSprite2D.play("Attack")
	
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

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Attack":
#		CurrentState = PlayerStates.MOVE
		$AttackCollision/CollisionShape2D.disabled = true
		isAttacking = false
		

#func OnStateFinished():
#	CurrentState = PlayerStates.MOVE
