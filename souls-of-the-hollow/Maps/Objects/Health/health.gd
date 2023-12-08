class_name Health
extends RigidBody2D

func verify_player() -> bool:
	for i in range($Area2D.get_overlapping_bodies().size()):
		if $Area2D.get_overlapping_bodies()[i].name == "Player":
			return true
	return false

func _input(event):
	if event.is_action_pressed("interact") and verify_player():
		if $Area2D.get_overlapping_bodies().size() > 1:
			await game_controller.apply_player_effect("Health")
			queue_free()
