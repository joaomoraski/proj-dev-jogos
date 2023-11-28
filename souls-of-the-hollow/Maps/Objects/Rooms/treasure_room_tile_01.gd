extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_controller.init($Player, $Player/Camera2D, $PrincipalUI/ProgressBar)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if $WallAndDoors.is_layer_enabled(1):
			return
		for i in range(1,5):
			$WallAndDoors.set_layer_enabled(i, true)
		for i in range(0,4):
			$Entries.get_child(i).monitoring = false
