class_name LabelVida
extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = "Vida: " + str(game_controller.player_life) + " | Times: " + str(game_controller.times_finished)
