class_name AngelBoss
extends CharacterBody2D

@export var damage_node: PackedScene
var coin_scene = preload("res://Maps/Objects/Coin/coin.tscn")
var BASE_HEALTH = 500
var health = 500
var drop_done: bool = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var _player: Player
var bossMap: BossMap
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var enemy_attack_name
var enemy_name
var rotation_index: int = 0
var start_boss: bool = false
var apply_gravity: bool = false
var back_position: bool = false
var dead: bool = false

func _ready():
#	$AnimationPlayer.play("Idle")
	randomize()

func set_player(player: Player):
	_player = player
	
func set_map(map: BossMap):
	bossMap = map

func setup(map: BossMap):
	set_map(map)
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
	if not dead:
		shield_rotation()
		if apply_gravity:
			$AnimationPlayer.play("Stunned")
			velocity.y += gravity * delta
		if back_position:
			velocity.y -= gravity * delta
		if position.y <= 70 and back_position:
			back_position = false
			velocity = Vector2(0,0)
		verify_death()
	move_and_slide()
	
func _on_stunned_animation_finished():
	$Escudo.visible = true
	apply_gravity = false
	back_position = true
	$AnimationPlayer.play("Idle")

func verify_death():
	if health <= 0:
		dead = true
		$AnimationPlayer.play("Stunned")
		$Hitbox/CollisionShape2D.disabled = true
		$Hitbox.set_deferred("monitoring", false)
		bossMap.open_exit_door()
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
		coin.position.y -= randf_range(25,100)
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
	
func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision":
		health -= game_controller.player_damage
		game_controller.get_camera().shake_camera(3, 0.3)
		popup(str(game_controller.player_damage))
