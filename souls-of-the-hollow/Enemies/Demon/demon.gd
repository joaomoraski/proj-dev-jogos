class_name Demon
extends BaseEnemy

func _ready():
	speed = 25
	BASE_HEALTH = 120
	BASE_DAMAGE = 40
	health = BASE_HEALTH
	damage = BASE_DAMAGE
	enemy_attack_name = "demonAttack"
	enemy_name = "Demon"
	$AnimationPlayer.play("Idle")
	randomize()
	setup()
