class_name FireSkeleton
extends BaseEnemy

func _ready():
	speed = 20
	BASE_HEALTH = 210
	BASE_DAMAGE = 30
	health = BASE_HEALTH
	damage = BASE_DAMAGE
	enemy_attack_name = "fireSkeletonAttack"
	enemy_name = "FireSkeleton"
	$AnimationPlayer.play("Idle")
	randomize()
	setup()
