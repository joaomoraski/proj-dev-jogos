class_name GameController
extends Node

var _player: Player
var _player_health_bar: ProgressBar
var _camera: Camera2D

# GLOBAL VARIABLES
############################################
var player_health
var no_reset_life: bool = false
var player_damage
var player_max_health
var times_finished = 0
var enemies_damage = {
	"Slime": 10
}
# PRIVATE METHODS
############################################

# PUBLIC METHODS
############################################
func init(player, camera, player_health_bar) -> void:
	_player = player
	_player_health_bar = player_health_bar
	_camera = camera
	get_tree().call_group("player_healthbar", "set_player_health_bar", _player_health_bar)
#	get_tree().call_group("enemies", "set_player", _player)
#	get_tree().call_group("breakables", "set_player", _player)
	get_tree().call_group("timerDash", "set_player", _player)

func get_camera() -> Camera2D:
	return _camera

func setup_enemy_damage(enemy, damage):
	enemies_damage[enemy] = damage
