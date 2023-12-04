class_name PowerUpTimer
extends Node2D

@onready var timer = $PowerUpTimer
# Precisa setar para one shot
var _type: String

func start_powerup_timer(duration, type):
	timer.wait_time = duration
	timer.start()
	_type = type

func _on_power_up_timer_timer_timeout():
	game_controller.remove_player_effect(_type)
