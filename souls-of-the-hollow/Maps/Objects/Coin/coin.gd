extends RigidBody2D

var coinValue: int = 10

func _input(event):
	if event.is_action_pressed("interact"):
		if $Area2D.get_overlapping_bodies().size() > 1:
			game_controller.player_coins += coinValue
			queue_free()
