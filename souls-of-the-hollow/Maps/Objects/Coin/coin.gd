extends RigidBody2D

var coinValue: int = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("interact"):
		if $Area2D.get_overlapping_bodies().size() > 1:
			game_controller.player_coins += coinValue
			queue_free()
