class_name Slime
extends CharacterBody2D


var speed = 30
var health = 10
#const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _player: Player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _motion: Vector2
var player_is_on_area = false

func set_player(player: Player):
	_player = player

func _ready():
	$AnimationPlayer.play("Idle")

func _physics_process(delta):
	# Adiciona a gravidade ao jogo
	velocity.y += gravity * delta
	Move()
	
func Move():
	if player_is_on_area:
		# Aumenta velocidade quando ele estiver mais longe
		_motion = (position.direction_to(_player.position) * speed) * (position.distance_to(_player.position)*0.1)
		velocity.x = _motion.x
	
	if health <= 0:
		velocity.x = 0 
		$AnimationPlayer.play("Dead")
		$CollisionShape2D.disabled = true
		await $AnimationPlayer.animation_finished
		queue_free()
		
	move_and_slide()
#
func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision":
		health -= _player.damage
		velocity.y = -200

func _on_vision_box_body_entered(body):
	if body.name == "Player":
		player_is_on_area = true

func _on_vision_box_body_exited(body):
	if body.name == "Player":
		player_is_on_area = false
		velocity.x = 0
