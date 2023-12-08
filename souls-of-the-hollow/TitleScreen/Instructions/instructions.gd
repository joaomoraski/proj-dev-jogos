extends Node2D

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		queue_free()

func _on_touch_screen_button_pressed():
	queue_free()
