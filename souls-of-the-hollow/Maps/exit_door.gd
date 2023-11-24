class_name ExitDoor
extends Area2D

func _ready():
	pass
	
func _input(event):
	if event.is_action_pressed("interact"):
		if get_overlapping_bodies().size() > 1:
			next_level()
			
# Essa logica aq é so quando matar o boss fina lta, to usando agora ja pra deixar adaptado

func next_level():
	game_controller.actual_stage+=1
	var path = str(game_controller.actual_stage)
	var stage = load("res://Maps/0" + path + "/map_0" + path + ".tscn")
	game_controller.change_stage(stage)
