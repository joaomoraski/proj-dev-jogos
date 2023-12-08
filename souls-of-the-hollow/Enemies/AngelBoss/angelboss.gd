class_name AngelBoss
extends CharacterBody2D

@export var damage_node: PackedScene
var coin_scene = preload("res://Maps/Objects/Coin/coin.tscn")
# Finite state machine
enum EnemyStates {MOVE, ATTACK, DEAD, HURT} # Array padrao, 0, 1, 2, 3 , HURT, DEAD 
var CurrentState = EnemyStates.MOVE # Estado atual do inimigo

var BASE_HEALTH = 500
var health = 500
var drop_done: bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var _player: Player
#var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var enemy_attack_name
var enemy_name
var rotation_index: int = 0
var start_boss: bool = false

func _ready():
#	$AnimationPlayer.play("Idle")
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

func init_boss():
	$AnimationPlayer.play("Idle")
	rotation_index = 0
	start_boss = true

func shield_rotation():
	if start_boss:
		$Escudo.rotation_degrees = 24 + (rotation_index * 24)
		if $Escudo.rotation_degrees >= 360:
			$Escudo.rotation_degrees = 0
			rotation_index=0
		rotation_index+=1

func _physics_process(delta):
	shield_rotation()
#	print($Escudo.rotation_degrees)
			
	# 3 segundos para bater no boss
	# Teleportar o player para o o lado do boss
#	$AnimationPlayer.play("Stunned")
#	await $AnimationPlayer.animation_finished
	pass
	# Adiciona a gravidade ao jogo
#	 velocity.y += gravity * delta
	
func _on_stunned_animation_finished():
	print("acabo")
#	$AnimationPlayer.play("Idle")


func verify_death():
	if health <= 0:
		CurrentState = EnemyStates.DEAD
		$AnimationPlayer.play("Stunned")
		$Hitbox/CollisionShape2D.disabled = true
		await $AnimationPlayer.animation_finished
		drop_itens()
		queue_free()

func drop_itens():
	if drop_done: return
	drop_coins(10)
	drop_done = true

func drop_coins(quantity: int):
	for i in range(quantity):
		var coin = coin_scene.instantiate()
		coin.position = position
		coin.position.x += randf_range(0,100)
		coin.position.y += randf_range(10,75)
		coin.coinValue = randi_range(0,75)
		get_tree().get_root().get_child(1).get_child(3).add_child(coin)

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
	pass
#	if is_on_floor() and $AnimationPlayer.current_animation != "Attack":
#		if velocity.x == 0.0:
#			$AnimationPlayer.play("Idle")
#		else:
#			$AnimationPlayer.play("Walk")


func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision" and CurrentState != EnemyStates.DEAD and CurrentState != EnemyStates.HURT:
		CurrentState = EnemyStates.HURT
		health -= game_controller.player_damage
		game_controller.get_camera().shake_camera(3, 0.3)
		popup(str(game_controller.player_damage))
		
func on_attack_animation_finished():
	CurrentState = EnemyStates.MOVE
	$AnimationPlayer.play("Idle")
