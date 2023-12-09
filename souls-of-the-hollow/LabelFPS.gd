class_name LabelFPS
extends Label

func _process(_delta):
	text = "FPS: " + str(Engine.get_frames_per_second()) + " | Times: " + str(game_controller.times_finished) + " " + str(game_controller.player_health) + " " + str(game_controller.actual_stage)
