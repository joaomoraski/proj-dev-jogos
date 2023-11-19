class_name ExitDoor
extends Area2D

@export var target_scene: PackedScene

func _ready():
	pass
	
func _input(event):
	if event.is_action_pressed("interact"):
#		if !target_scene: # is null
#			print("tem nada aqui")
#			return
		if get_overlapping_bodies().size() > 1:
			next_level()
			
# Essa logica aq é so quando matar o boss fina lta, to usando agora ja pra deixar adaptado

func next_level():
	game_controller.times_finished += 1
	game_controller.no_reset_life = true
	get_tree().reload_current_scene()
	pass
