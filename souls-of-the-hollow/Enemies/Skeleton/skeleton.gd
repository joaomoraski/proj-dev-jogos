class_name Skeleton
extends CharacterBody2D

@export var damage_node: PackedScene
# Finite state machine
enum SkeletonStates {MOVE, ATTACK, DEAD, HURT} # Array padrao, 0, 1, 2, 3 , HURT, DEAD 
var CurrentState = SkeletonStates.MOVE # Estado atual do personagem


var speed = 28
const BASE_HEALTH = 180
const BASE_DAMAGE = 25
var _is_moving_left: bool = true
var _can_attack: bool = true
var _can_move: bool = true
var cooldown_time: float = 1.5  # Tempo de cooldown em segundos
var cooldown_timer: float = 0.0  # Temporizador para controlar o cooldown

var health = 180
var damage = 25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _player: Player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _motion: Vector2
var player_is_on_area = false
var anterior_position

func _ready():
	$AnimationPlayer.play("Idle")
	randomize()
	setup()

func set_player(player: Player):
	_player = player

func setup():
	set_player(game_controller._player)
	var times = game_controller.times_finished
	if times:
		var multiplier = 0.05 * times
		health += BASE_HEALTH * multiplier
		damage += BASE_DAMAGE * multiplier
		game_controller.setup_enemy_damage("Skeleton", damage)

func _physics_process(delta):
	if anterior_position == position and not player_is_on_area and CurrentState != SkeletonStates.ATTACK:
		invert_moving()
	anterior_position = position
	attack_logic(delta)
	if _can_move and CurrentState == SkeletonStates.HURT:
		CurrentState = SkeletonStates.MOVE
		$Hitbox.monitoring = true
	# Adiciona a gravidade ao jogo
	velocity.y += gravity * delta
	if CurrentState == SkeletonStates.MOVE:
		Move()
	verify_death()
	move_and_slide()
	
func verify_death():
	if health <= 0:
		velocity = Vector2(0,0)
		CurrentState = SkeletonStates.DEAD
		$AnimationPlayer.play("Dead")
		$CollisionShape2D.disabled = true
		$Hitbox/CollisionShape2D.disabled = true
		await $AnimationPlayer.animation_finished
		queue_free()

func attack_logic(delta):
	# Atualizar o temporizador de cooldown
	cooldown_timer = max(0, cooldown_timer - delta)
	# Deixa o inimigo atacar
	_can_attack = cooldown_timer <= 0;
	_can_move = cooldown_timer <= 0;

func popup(message: String):
	var node = damage_node.instantiate()
	node.get_child(0).text = message
	node.position = global_position
	var tween = get_tree().create_tween()
	tween.tween_property(node, "position", global_position + _get_direction(), 0.75)
	get_tree().current_scene.add_child(node)

func _get_direction():
	return Vector2(randf_range(-1, 1), -randf()) * 16
	
# Esquerda -1
# direita 1
func Move():
	if player_is_on_area and position.distance_to(_player.position) <= 15.0 and _can_attack:
		$AnimationPlayer.play("Attack")
		cooldown_timer = cooldown_time

	if $AnimationPlayer.current_animation == "Attack":
		return
	velocity.x = -speed if _is_moving_left else speed
	detect_turn_around()
	
func invert_moving():
	_is_moving_left = !_is_moving_left
	scale.x = -scale.x
#
func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision" and CurrentState == SkeletonStates.MOVE:
		CurrentState = SkeletonStates.HURT
		$Hitbox.monitoring = false
		cooldown_timer = cooldown_time
		health -= game_controller.player_damage
		velocity = Vector2((speed*-1) * 2,-200)
		game_controller.get_camera().shake_camera(3, 0.3)
		popup(str(game_controller.player_damage))
	if area.name == "PresenceCollision":
		invert_moving()
		
func _on_vision_box_body_entered(body):
	if body.name == "Player":
		player_is_on_area = true
		var direction_to_player = position.direction_to(body.position)
		# Obtém o ângulo entre a direção atual do inimigo e a direção para o jogador
		var direction = Vector2(cos(rotation), sin(rotation))
		var angle_difference = direction.angle_to(direction_to_player)
		# Define um limiar de ângulo (por exemplo, 90 graus)
		var limiar_angular = deg_to_rad(90)
		# Verifica se o jogador está atrás do inimigo
		if abs(angle_difference) > limiar_angular:
			# O jogador está atrás do inimigo
			invert_moving()
	if body.is_in_group("breakables") or body.is_in_group("chests"):
		invert_moving()

func _on_vision_box_body_exited(body):
	if body.name == "Player":
		player_is_on_area = false

func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		invert_moving()
		
func on_attack_animation_finished():
	$AnimationPlayer.play("Idle")
