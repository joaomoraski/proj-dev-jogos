extends Node2D


var selected_option: int = 0
var past_option: int = 0
var selected_color: Color = Color(0,1,1,1)
var buttons_index = {}
var buttons_index_color = {}
enum {STARTBUTTON, INSTRUCTIONBUTTON, CREDITSBUTTON, EXITBUTTON}

# Called when the node enters the scene tree for the first time.
func _ready():
	buttons_index = {
		STARTBUTTON: $Buttons/StartGame,
		INSTRUCTIONBUTTON: $Buttons/Instructions,
		CREDITSBUTTON: $Buttons/Credits,
		EXITBUTTON: $Buttons/ExitGame
	}
	
	buttons_index_color = {
		STARTBUTTON: $Buttons/StartGame/StartGameColor,
		INSTRUCTIONBUTTON: $Buttons/Instructions/InstructionsColor,
		CREDITSBUTTON: $Buttons/Credits/CreditsColor,
		EXITBUTTON: $Buttons/ExitGame/ExitGameColor
	}

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		if selected_option > 0:
			past_option = selected_option
			selected_option -=1
	if Input.is_action_just_pressed("ui_down"):
		if selected_option < 3:
			past_option = selected_option
			selected_option +=1
	if Input.is_action_just_pressed("ui_accept"):
		match selected_option:
			STARTBUTTON:
				get_tree().change_scene_to_file("res://world.tscn")
			INSTRUCTIONBUTTON:
				print("Instructions button")
			CREDITSBUTTON:
				print("Credits button")
			EXITBUTTON:
				get_tree().quit()
	change_button_color()

func change_button_color():
	buttons_index_color[selected_option].color = selected_color
	if selected_option != past_option:
		buttons_index_color[past_option].color = Color(1,1,1,1)
	
func _on_start_touch_screen_pressed():
	pass # Replace with function body.

func _on_instruction_touch_screen_pressed():
	pass # Replace with function body.

func _on_credits_touch_screen_pressed():
	pass # Replace with function body.

func _on_exit_game_touch_screen_pressed():
	pass # Replace with function body.
