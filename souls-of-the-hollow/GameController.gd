class_name GameController
extends Node

var _player: Player
var _camera: Camera2D

# GLOBAL VARIABLES
############################################
var player_life = 100
var player_damage = 25
var times_finished = 0
var enemies_damage = {
	"Slime": 10
}
# PRIVATE METHODS
############################################

# PUBLIC METHODS
############################################
func init(player, camera) -> void:
	_player = player
	_camera = camera
	get_tree().call_group("enemies", "set_player", _player)
	get_tree().call_group("breakables", "set_player", _player)
	get_tree().call_group("timerDash", "set_player", _player)

func get_camera() -> Camera2D:
	return _camera

func setup_player(life, damage):
	player_life = life
	player_damage = damage
	
	if times_finished:
		player_life += (100 * (0.02 * game_controller.times_finished))
		player_damage += (25 * (0.02 * game_controller.times_finished))
	
func setup_enemy_damage(enemy, damage):
	enemies_damage[enemy] = damage
