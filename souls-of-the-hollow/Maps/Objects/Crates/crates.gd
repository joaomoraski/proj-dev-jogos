class_name Crate
extends StaticBody2D

@export var health = 10;

var _player: Player

func _init() -> void:
	set_player(game_controller._player)

func set_player(player: Player):
	_player = player

func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision":
		$anim.play("Hurt")
		health -= game_controller.player_damage
		await $anim.animation_finished
		$anim.play("Active")
	
	if health <= 0:
		$anim.play("Destroyed")
		$CollisionShape2D.set_deferred("disabled", true)
		await $anim.animation_finished
		queue_free()
