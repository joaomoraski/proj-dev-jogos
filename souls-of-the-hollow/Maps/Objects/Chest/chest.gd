class_name Chest
extends RigidBody2D

var coin_scene = preload("res://Maps/Objects/Coin/coin.tscn")
var health_scene = preload("res://Maps/Objects/Health/health.tscn")
var demon_sword_scene = preload("res://Maps/Objects/PowerUps/DemonSword/demon_sword.tscn")

func verify_player() -> bool:
	for i in range($OpenArea.get_overlapping_bodies().size()):
		if $OpenArea.get_overlapping_bodies()[i].name == "Player":
			return true
	return false

func _input(event):
	if event.is_action_pressed("interact"):
		if $OpenArea.monitoring and $OpenArea.get_overlapping_bodies().size() > 1 and verify_player():
			$OpenArea.set_deferred("monitoring", false)
			visible = false
			drop_coins(5)
			drop_health(3)
			if randf() <= 0.10:
				drop_demon_sword()
			queue_free()


func drop_demon_sword():
	var demon_sword = demon_sword_scene.instantiate()
	demon_sword.position = position
	demon_sword.position.x += randf_range(0,25)
	demon_sword.position.y += 10
	get_tree().get_root().get_child(1).get_child(3).add_child(demon_sword)

func drop_health(quantity: int):
	for i in range(quantity):
		var health_drop = health_scene.instantiate()
		health_drop.position = position
		health_drop.position.x += randf_range(0,25)
		health_drop.position.y += 10
		get_tree().get_root().get_child(1).get_child(3).add_child(health_drop)


func drop_coins(quantity: int):
	for i in range(quantity):
		var coin = coin_scene.instantiate()
		coin.position = position
		coin.position.x += randf_range(0,25)
		coin.position.y += 10
		coin.coinValue = randi_range(50,125)
		get_tree().get_root().get_child(1).get_child(3).add_child(coin)
