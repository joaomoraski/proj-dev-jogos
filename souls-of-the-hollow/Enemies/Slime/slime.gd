class_name Slime
extends BaseEnemy

func _ready():
	speed = 32
	BASE_HEALTH = 100
	BASE_DAMAGE = 10
	health = BASE_HEALTH
	damage = BASE_DAMAGE
	enemy_attack_name = "Slime"
	enemy_name = "Slime"
	$AnimationPlayer.play("Idle")
	randomize()
	setup()

func setup():
	var prob_black_slime = 40 # %
	set_player(game_controller._player)
	var times = game_controller.times_finished
	var multiplier = 0.05 * times
	if times:
		health += BASE_HEALTH * multiplier
		damage += BASE_DAMAGE * multiplier
		game_controller.setup_enemy_damage("Slime", damage)
	if game_controller.actual_stage > 1 and randf_range(0,100) < prob_black_slime:
		health += (25 * (multiplier if multiplier else 1.0))
		damage += (7 * (multiplier if multiplier else 1.0))
		$AttackBox.remove_from_group("Slime")
		$AttackBox.add_to_group("BlackSlime")
		$Sprite2D.modulate = Color(1, 0, 0, 1)
		game_controller.setup_enemy_damage("BlackSlime", damage)
		enemy_name = "BlackSlime"
