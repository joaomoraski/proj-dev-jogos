class_name TripleDAmageDoubleTaken
extends RigidBody2D

@onready var powerup = $PowerUpsTimes

func verify_player() -> bool:
	for i in range($Area2D.get_overlapping_bodies().size()):
		if $Area2D.get_overlapping_bodies()[i].name == "Player":
			return true
	return false

func _input(event):
	if event.is_action_pressed("interact"):
		if $Area2D.get_overlapping_bodies().size() > 1 and verify_player():
			$Area2D.monitoring = false
			visible = false
			await game_controller.apply_player_effect("TripleDamageDoubleTaken")
			powerup.start_powerup_timer(5, "TripleDamageDoubleTaken")
			await get_tree().create_timer(5).timeout
			queue_free()
