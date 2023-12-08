class_name BaseEnemy
extends CharacterBody2D

@export var damage_node: PackedScene
var coin_scene = preload("res://Maps/Objects/Coin/coin.tscn")
var health_scene = preload("res://Maps/Objects/Health/health.tscn")
enum {DOUBLEDAMAGE, SPEED, TRIPLEDAMAGEDOUBLETAKEN}
var drops_scenes = {
	DOUBLEDAMAGE: "res://Maps/Objects/PowerUps/DoubleDamage/double_damage.tscn",
	SPEED: "res://Maps/Objects/PowerUps/Speed/speed.tscn",
	TRIPLEDAMAGEDOUBLETAKEN: "res://Maps/Objects/PowerUps/TripleDamageDoubleTaken/triple_damage_double_taken.tscn"
}
# Finite state machine
enum EnemyStates {MOVE, ATTACK, DEAD, HURT} # Array padrao, 0, 1, 2, 3 , HURT, DEAD 
var CurrentState = EnemyStates.MOVE # Estado atual do inimigo

var speed = 32
var BASE_HEALTH = 100
var BASE_DAMAGE = 10
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
var enemy_attack_name
var enemy_name
var enemy_probability_levels = {
	"Slime": 1,
	"BlackSlime": 1.5,
	"Skeleton": 2,
	"FireSkeleton": 2.5,
	"Demon": 3
}

func _ready():
	$AnimationPlayer.play("Idle")
	randomize()
	setup()

func set_player(player: Player):
	_player = player

func setup():
	set_player(game_controller._player)
	var times = game_controller.times_finished
	var multiplier = 0.05 * times
	if times:
		health += BASE_HEALTH * multiplier
		damage += BASE_DAMAGE * multiplier
		game_controller.setup_enemy_damage(enemy_attack_name, damage)

func _physics_process(delta):
	# Logica para ele nao ficar preso na mesma posição caso algo o trave
	if anterior_position == position and not player_is_on_area and CurrentState != EnemyStates.ATTACK:
		invert_moving()
	anterior_position = position
	attack_logic(delta)
	if _can_move and (CurrentState == EnemyStates.HURT or not $Hitbox.monitoring):
		CurrentState = EnemyStates.MOVE
		$Hitbox.set_deferred("monitoring", true)
	# Adiciona a gravidade ao jogo
	velocity.y += gravity * delta
	if CurrentState == EnemyStates.MOVE:
		Move()
	verify_death()
	move_and_slide()
	
func verify_death():
	if health <= 0:
		velocity = Vector2(0,0)
		CurrentState = EnemyStates.DEAD
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
	if get_probability_drops("Health"):
		drop_health(randi_range(1,2))
	if get_probability_drops("PowerUp"):
		drop_power_up()
	drop_done = true

func drop_health(quantity: int):
	for i in range(quantity):
		var health_drop = health_scene.instantiate()
		health_drop.position = position
		health_drop.position.x += randf_range(0,25)
		health_drop.position.y += 10
		get_tree().get_root().get_child(1).get_child(3).add_child(health_drop)
	
func drop_power_up():
	var powerup_drop = load(drops_scenes[randi_range(0,2)]).instantiate()
	powerup_drop.position = position
	powerup_drop.position.x += randf_range(0,25)
	powerup_drop.position.y += 10
	get_tree().get_root().get_child(1).get_child(3).add_child(powerup_drop)

func drop_coins(quantity: int):
	for i in range(quantity):
		var coin = coin_scene.instantiate()
		coin.position = position
		coin.position.x += randf_range(0,25)
		coin.position.y += 10
		coin.coinValue = randi_range(0,75)
		get_tree().get_root().get_child(1).get_child(3).add_child(coin)


# Enemy Levels
# Slime 1
# BlackSlime 1.5
# Skeleton 2
# FireSkeleton 2.5
# Demon 3
# 60% - 5% a cada fase que passou - 3 * levels
func get_probability_drops(drop: String):
	var probability = 0
	if drop == "Coin" or drop == "Health":
		probability = 0.25
	else:
		probability = 0.60 - ((0.05 * game_controller.actual_stage) + (0.03*enemy_probability_levels[enemy_name]))
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
	if is_on_floor() and $AnimationPlayer.current_animation != "Attack":
		if velocity.x == 0.0:
			$AnimationPlayer.play("Idle")
		else:
			$AnimationPlayer.play("Walk")
	
	if player_is_on_area and get_global_position().distance_to(_player.get_global_position()) <= 20.0 and _can_attack:
		$AnimationPlayer.play("Attack")
		cooldown_timer = cooldown_time
		CurrentState = EnemyStates.ATTACK

	if $AnimationPlayer.current_animation == "Attack":
		return
	velocity.x = speed if _is_moving_right else -speed
	detect_turn_around()
	
func invert_moving():
	if CurrentState != EnemyStates.MOVE:
		return
	_is_moving_right = !_is_moving_right
	scale.x = -scale.x
#
func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision" and CurrentState != EnemyStates.DEAD and CurrentState != EnemyStates.HURT:
		CurrentState = EnemyStates.HURT
		$Hitbox.set_deferred("monitoring", false)
		cooldown_timer = cooldown_time
		velocity.x = 0
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
	if body.is_in_group("breakables") or body.is_in_group("chests") or body.is_in_group("enemies"):
		invert_moving()

func _on_vision_box_body_exited(body):
	if body.name == "Player":
		player_is_on_area = false

func detect_turn_around():
	if not $RayCast2D.is_colliding() and is_on_floor():
		invert_moving()
		
func on_attack_animation_finished():
	CurrentState = EnemyStates.MOVE
	$AnimationPlayer.play("Idle")
