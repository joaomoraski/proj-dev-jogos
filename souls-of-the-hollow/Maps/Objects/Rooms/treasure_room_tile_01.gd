class_name TreasureRoom01
extends Node2D

@export var enemy_scene: PackedScene

var spawn_enemies: bool = false;
@export var enemies_total = 12
var enemies_on_screen = 0
#var monster_per_spawn = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
#	game_controller.init($Player, $Player/Camera2D, $PrincipalUI/ProgressBar)
#	calculate_monster_per_spawn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spawn_enemies:
		generate_enemies()
	if enemies_total == 0:
		spawn_enemies = false
	pass

#func calculate_monster_per_spawn() -> void:
#	var total_temp = enemies_total
#	if total_temp%3 != 0:
#		var per_spawn = total_temp/3
#		for i in range(2):
#			monster_per_spawn[i] = per_spawn
#			total_temp-=per_spawn
#		monster_per_spawn[2] = total_temp
#	else:
#		for i in range(3):
#			monster_per_spawn[i] = total_temp/3

func generate_enemies() -> void:
	if enemies_on_screen >= 3:
		return
	var enemy = await enemy_scene.instantiate()
	enemy.position = get_random_spawner_position()
	enemy.is_from_spawner = true
	enemy.die_on_spawner.connect(on_enemy_die)	
	add_child(enemy)
	enemies_on_screen+=1
	enemies_total-=1
	await get_tree().create_timer(1).timeout
	
	
func get_random_spawner_position() -> Vector2:
	var rand = randi_range(1,3)
	match rand:
		1:
			return $"Spawners/Spawner 1/CollisionShape2D".position
		2: 
			return $"Spawners/Spawner 2/CollisionShape2D".position
		3:
			return $"Spawners/Spawner 3/CollisionShape2D".position
	# Retorno default
	return $"Spawners/Spawner 1/CollisionShape2D".position

func _on_door_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		await get_tree().create_timer(0.2).timeout
		if $WallAndDoors.is_layer_enabled(1):
			return
		for i in range(1,5):
			$WallAndDoors.set_layer_enabled(i, true)
		for i in range(0,4):
			$Entries.get_child(i).monitoring = false
		spawn_enemies = true


func on_enemy_die():
	enemies_on_screen-=1
