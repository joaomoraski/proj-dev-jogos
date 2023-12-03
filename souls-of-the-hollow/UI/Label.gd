class_name LabelPosition
extends Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	text = "Player Position: " + str(game_controller._player.position)
