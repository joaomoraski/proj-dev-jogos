class_name PowerUpTimer
extends Node2D

@onready var timer = $PowerUpTimer
# Precisa setar para one shot
var _player: Player
var type: String

func set_player(player: Player):
	_player = player

func start_powerup_timer(duration, type):
	timer.wait_time = duration
	timer.start()

func _on_power_up_timer_timer_timeout():
	print("aaaaaaaaaaa")
