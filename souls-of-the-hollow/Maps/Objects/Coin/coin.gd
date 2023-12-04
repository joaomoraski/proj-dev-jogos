extends RigidBody2D

var coinValue: int = 10

func verify_player() -> bool:
	for i in range($Area2D.get_overlapping_bodies().size()):
		if $Area2D.get_overlapping_bodies()[i].name == "Player":
			return true
	return false

func _input(event):
	if event.is_action_pressed("interact"):
		if $Area2D.get_overlapping_bodies().size() > 1 and verify_player():
			game_controller.player_coins += coinValue
			queue_free()
