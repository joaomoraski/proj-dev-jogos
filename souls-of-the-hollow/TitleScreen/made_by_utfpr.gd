extends Node2D

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file("res://TitleScreen/title_screen.tscn")	
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_file("res://TitleScreen/title_screen.tscn")
