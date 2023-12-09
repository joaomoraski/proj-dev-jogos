class_name ExitDoor
extends Area2D


func verify_player() -> bool:
	for i in range(get_overlapping_bodies().size()):
		if get_overlapping_bodies()[i].name == "Player":
			return true
	return false
	
func _input(event):
	if monitoring and event.is_action_pressed("interact"):
		if get_overlapping_bodies().size() >= 1 and verify_player():
			next_level()
			
# Essa logica aq é so quando matar o boss fina lta, to usando agora ja pra deixar adaptado

func next_level():
	game_controller.actual_stage+=1
	if game_controller.actual_stage > 7:
		game_controller.actual_stage = 1
		game_controller.times_finished+=1
	var path = str(game_controller.actual_stage)
	var stage = load("res://Maps/0" + path + "/map_0" + path + ".tscn")
	game_controller.change_stage(stage)
