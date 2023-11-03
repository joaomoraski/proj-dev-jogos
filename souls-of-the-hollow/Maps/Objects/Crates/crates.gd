class_name Crate
extends StaticBody2D

@export var health = 20;

var _player: Player

func set_player(player: Player):
	_player = player

func _ready():
	pass

func _on_hitbox_area_entered(area):
	if area.name == "AttackCollision":
		$anim.play("Hurt")
		health -= _player.damage
		await $anim.animation_finished
		$anim.play("Active")
	
	if health <= 0:
		$anim.play("Destroyed")
		$CollisionShape2D.disabled = true
		await $anim.animation_finished
		queue_free()
