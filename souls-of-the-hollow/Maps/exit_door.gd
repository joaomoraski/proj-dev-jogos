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
			
func next_level():
	game_controller.times_finished += 1
	game_controller.setup_player(game_controller.player_life, 25)
	get_tree().reload_current_scene()
	pass
