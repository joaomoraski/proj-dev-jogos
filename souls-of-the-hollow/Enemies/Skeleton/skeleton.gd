class_name Skeleton
extends BaseEnemy

func _ready():
	speed = 20
	BASE_HEALTH = 10
	BASE_DAMAGE = 25
	health = BASE_HEALTH
	damage = BASE_DAMAGE
	enemy_name = "Skeleton"
	$AnimationPlayer.play("Idle")
	randomize()
	setup()
