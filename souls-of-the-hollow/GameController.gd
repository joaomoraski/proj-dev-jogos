class_name GameController
extends Node

var _player: Player
var _player_health_bar: ProgressBar
var _camera: Camera2D

# GLOBAL VARIABLES
############################################
var no_reset_life: bool = false
var player_coins: int = 0
var player_health = 100
var player_damage = 25
var player_max_health = 100
var actual_stage = 1
var boss_stages = [3,6,9]
var maps_positions_list = {
	0: Vector2(100,100),
	1: Vector2(29, 48),
	2: Vector2(25, 144)
}
var times_finished = 0
# Default
var enemies_damage = {
	"Slime": 10,
	"BlackSlime": 17,
	"skeletonAttack": 25,
	"fireSkeletonAttack": 30,
	"demonAttack": 40
}

var base_demon_sword_damage = 25
# PRIVATE METHODS
############################################

# PUBLIC METHODS
############################################
func init(player, camera, player_health_bar) -> void:
	_player = player
	_player_health_bar = player_health_bar
	_camera = camera
	get_tree().call_group("player_healthbar", "set_player_health_bar", _player_health_bar)
	get_tree().call_group("timerDash", "set_player", _player)
	get_tree().call_group("power_up_dash", "set_player", _player)

func get_camera() -> Camera2D:
	return _camera

func get_player() -> Player:
	return _player

func reset_player():
	player_health = 100
	player_damage = 25
	player_max_health = 100
	_player.setup()

func apply_player_effect(type: String):
	if type == "Speed":
		_player.normalSpeed *= 2 
	if type == "DoubleDamage":
		# Todo, verificar se esta com a espada
		game_controller.player_damage *= 2
	if type == "TripleDamageDoubleTaken":
		game_controller.player_damage *= 3
		_player.double_damage_taken = true
	if type == "DemonSword":
		# So perde quando morrer
		_player.have_demon_sword = true
		# Dano bonus base da demon sword vai ser 25
		if times_finished:
			var multiplier = 0.02 * times_finished
			player_damage += (base_demon_sword_damage * multiplier)
		else:
			player_damage += base_demon_sword_damage
	if type == "Health":
		if player_health < player_max_health:
			if player_health + 15 > player_max_health:
				player_health = player_max_health
			else:
				player_health += 15

func remove_player_effect(type: String):
	if type == "Speed":
		_player.normalSpeed = 150.0
	if type == "DoubleDamage":
		player_damage = 25
		# Todo, verificar se esta com a espada
		if _player.have_demon_sword and not times_finished:
			player_damage+=base_demon_sword_damage
			
		if times_finished:
			var multiplier = 0.02 * times_finished
			player_damage += (player_damage * multiplier)
			if _player.have_demon_sword:
				player_damage += (base_demon_sword_damage * multiplier)
				
	if type == "TripleDamageDoubleTaken":
		player_damage = 25
		_player.double_damage_taken = false
		# Todo, verificar se esta com a espada
		if times_finished:
			var multiplier = 0.02 * times_finished
			player_damage += (player_damage * multiplier)
	
func setup_enemy_damage(enemy, damage):
	enemies_damage[enemy] = damage

func change_stage(stage):
	get_tree().get_root().get_child(1).get_child(3).free()
	var next_stage = stage.instantiate()
	get_tree().get_root().get_child(1).add_child(next_stage)
	get_tree().get_root().get_child(1).get_node("Player").position = maps_positions_list[actual_stage]
