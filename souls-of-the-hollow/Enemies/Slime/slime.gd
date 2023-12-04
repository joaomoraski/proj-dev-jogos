class_name Slime
extends CharacterBody2D

@export var damage_node: PackedScene
var coin_scene = preload("res://Maps/Objects/Coin/coin.tscn")
# Finite state machine
enum SlimeStates {MOVE, ATTACK, DEAD, HURT} # Array padrao, 0, 1, 2, 3 , HURT, DEAD 
var CurrentState = SlimeStates.MOVE # Estado atual do personagem

var speed = 32
const BASE_HEALTH = 100
const BASE_DAMAGE = 10
var _is_moving_right: bool = true
var _can_attack: bool = true
var _can_move: bool = true
var cooldown_time: float = 1.5  # Tempo de cooldown em segundos
var cooldown_timer: float = 0.0  # Temporizador para controlar o cooldown
var is_from_spawner: bool = false
var drop_done: bool = false
signal die_on_spawner

var health = 100
var damage = 10

# Get the gravity from the project settings to be synced with RigidBody nodes.
var _player: Player
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_is_on_area = false
var anterior_position
var is_black_slime

func _ready():
	$AnimationPlayer.play("Idle")
	randomize()
	setup()

func set_player(player: Player):
	_player = player

func setup():
	var prob_black_slime = 40 # %
	set_player(game_controller._player)
	var times = game_controller.times_finished
	var multiplier = 0.05 * times
	if times:
		health += BASE_HEALTH * multiplier
		damage += BASE_DAMAGE * multiplier
		game_controller.setup_enemy_damage("Slime", damage)
	if game_controller.actual_stage > 1 and randf_range(0,100) < prob_black_slime:
		health += (25 * (multiplier if multiplier else 1))
		damage += (7 * (multiplier if multiplier else 1))
		$AttackBox.remove_from_group("Slime")
		$AttackBox.add_to_group("BlackSlime")
		$Sprite2D.modulate = Color(1, 0, 0, 1)
		game_controller.setup_enemy_damage("BlackSlime", damage)

func _physics_process(delta):
	# Logica para ele nao ficar preso na mesma posição caso algo o trave
	if anterior_position == position and not player_is_on_area and CurrentState != SlimeStates.ATTACK:
		invert_moving()
	anterior_position = position
	attack_logic(delta)
	if _can_move and CurrentState == SlimeStates.HURT:
		CurrentState = SlimeStates.MOVE
		$Hitbox.monitoring = true
	# Adiciona a gravidade ao jogo
	velocity.y += gravity * delta
	if CurrentState == SlimeStates.MOVE:
		Move()
	verify_death()
	move_and_slide()
	
func verify_death():
	if health <= 0:
		velocity = Vector2(0,0)
		CurrentState = SlimeStates.DEAD
		$AnimationPlayer.play("Dead")
		$CollisionShape2D.disabled = true
		$Hitbox/CollisionShape2D.disabled = true
		await $AnimationPlayer.animation_finished
		if is_from_spawner:
			emit_signal("die_on_spawner")
			is_from_spawner = false
		drop_itens()
		queue_free()

func drop_itens():
	if drop_done:
		return
	# For now, just coins
	if get_probability_drops("Coin"):
		drop_coins(3)
	drop_done = true
	
func drop_coins(quantity: int):
	for i in range(quantity):
		var coin = await coin_scene.instantiate()
		coin.position = position
		coin.position.x += randf_range(0,25)
		coin.position.y += 10
		coin.coinValue = randi_range(0,75)
		get_tree().get_root().get_child(1).get_child(3).add_child(coin)

func get_probability_drops(drop: String):
	var probability = 0
	if drop == "Coin":
		probability = 0.25
	if randf() < probability:
		return true
	else:
		return false


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
	
func Move():
	if player_is_on_area and get_global_position().distance_to(_player.get_global_position()) <= 15.0 and _can_attack:
		$AnimationPlayer.play("Attack")
		cooldown_timer = cooldown_time
		CurrentState = SlimeStates.ATTACK

	if $AnimationPlayer.current_animation == "Attack":
		return
	velocity.x = speed if _is_moving_right else -speed
	detect_turn_around()
	
func invert_moving():
	if CurrentState != SlimeStates.MOVE:
		return
	_is_moving_right = !_is_moving_right
	scale.x = -scale.x
#
func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision" and CurrentState != SlimeStates.DEAD:
		CurrentState = SlimeStates.HURT
		$Hitbox.monitoring = false
		cooldown_timer = cooldown_time
		health -= game_controller.player_damage
		game_controller.get_camera().shake_camera(3, 0.3)
		popup(str(game_controller.player_damage))
		
func _on_vision_box_body_entered(body):
	if body.name == "Player":
		player_is_on_area = true
		var direction_to_player = get_global_position().direction_to(body.get_global_position())
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
	CurrentState = SlimeStates.MOVE
	$AnimationPlayer.play("Idle")
