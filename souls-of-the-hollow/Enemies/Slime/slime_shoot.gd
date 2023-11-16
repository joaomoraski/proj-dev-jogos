extends Area2D

@export var speed = -250

func start(pos):
	position = pos

func _process(delta):
	position.y += speed * delta


func _on_area_entered(area: Area2D) -> void:
	# ve se é o player e gg
	if area.name == "Player":
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
