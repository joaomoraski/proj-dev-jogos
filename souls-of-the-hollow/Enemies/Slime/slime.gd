class_name Slime
extends CharacterBody2D

@export var damage_node: PackedScene

var speed = 30
const BASE_HEALTH = 100
const BASE_DAMAGE = 25

var health = 100
var damage = 25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _player: Player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _motion: Vector2
var player_is_on_area = false

func _ready():
	$AnimationPlayer.play("Idle")
	randomize()
	setup()

func set_player(player: Player):
	_player = player

func popup(message: String):
	var node = damage_node.instantiate()
	node.get_child(0).text = message
	node.position = global_position
	var tween = get_tree().create_tween()
	tween.tween_property(node, "position", global_position + _get_direction(), 0.75)
	get_tree().current_scene.add_child(node)

func _get_direction():
	return Vector2(randf_range(-1, 1), -randf()) * 16

func setup():
	var times = game_controller.times_finished
	if times:
		var multiplier = 0.05 * times
		health += BASE_HEALTH * multiplier
		damage += BASE_DAMAGE * multiplier
		game_controller.setup_enemy_damage("Slime", damage)


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
		$Hitbox/CollisionShape2D.disabled = true
		await $AnimationPlayer.animation_finished
		queue_free()
		
	move_and_slide()
#
func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision":
		health -= game_controller.player_damage
		velocity.y = -200
		game_controller.get_camera().shake_camera(3, 0.3)
		popup(str(game_controller.player_damage))

func _on_vision_box_body_entered(body):
	if body.name == "Player":
		player_is_on_area = true

func _on_vision_box_body_exited(body):
	if body.name == "Player":
		player_is_on_area = false
		velocity.x = 0
