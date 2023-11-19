class_name LabelVida
extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = "/ Vida máxima: " + str(game_controller.player_max_health) 
	
#" | Times: " + str(game_controller.times_finished)
