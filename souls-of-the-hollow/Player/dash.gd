class_name Dash
extends Node2D

@onready var timer = $DashTimer
# Precisa setar para one shot
var _player: Player

func set_player(player: Player):
	_player = player

func start_dash(duration):
	timer.wait_time = duration
	timer.start()

func is_dashing():
	return !timer.is_stopped()

func _on_dash_timer_timeout():
	_player.dash_collision_logic(true)
