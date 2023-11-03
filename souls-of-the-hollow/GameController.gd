class_name GameController
extends Node

var _player: Player
var _camera: Camera2D

# PRIVATE METHODS
############################################

# PUBLIC METHODS
############################################
func init(player, camera) -> void:
	_player = player
	_camera = camera
	get_tree().call_group("enemies", "set_player", _player)

func get_camera() -> Camera2D:
	return _camera
