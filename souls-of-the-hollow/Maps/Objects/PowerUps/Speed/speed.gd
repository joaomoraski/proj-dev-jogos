class_name Speed
extends RigidBody2D

@onready var dash = $PowerUpsTimes

func _input(event):
	if event.is_action_pressed("interact"):
		if $Area2D.get_overlapping_bodies().size() > 1:
			game_controller.get_player().SPEED = game_controller.get_player().SPEED*2
			dash.start_powerup_timer(10)
			queue_free()
