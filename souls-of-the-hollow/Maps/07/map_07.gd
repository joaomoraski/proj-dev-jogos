extends Node2D

var move_camera: bool = false
var camera_killed: bool = false
var spawn_mobs: bool = false
var all_enemies_die: bool = false
var number_mobs: int = 20
var number_mobs_save: int = 20
var health_enemies: int = 100
var enemies_on_screen: int = 0
var killed_enemies: int = 0
var enemies_scene = {
	0: "res://Enemies/Slime/slime.tscn",
	1: "res://Enemies/Skeleton/skeleton.tscn",
	2: "res://Enemies/FireSkeleton/fire_skeleton.tscn",
	3: "res://Enemies/Demon/demon.tscn"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if game_controller.times_finished:
		number_mobs += 20 + (2 * game_controller.times_finished)
		number_mobs_save += 20 + (2 * game_controller.times_finished)
		health_enemies += health_enemies * (game_controller.times_finished * 0.05)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spawn_mobs:
		generate_enemies()

	if killed_enemies >= number_mobs_save/4 and enemies_on_screen <= 0:
		killed_enemies = 0
		enemies_on_screen = 0
		spawn_mobs = false
		
	
	pass


func generate_enemies() -> void:
	if enemies_on_screen >= 4 or number_mobs <= 0: return
	var enemy = load(enemies_scene[randi_range(0,3)]).instantiate()
	enemy.position = get_random_spawner_position()
	enemy.health = health_enemies
	enemy.is_from_spawner = true
	enemy.die_on_spawner.connect(on_enemy_die)
	add_child(enemy)
	enemies_on_screen+=1
	number_mobs-=1
	await get_tree().create_timer(1).timeout
	
	
func get_random_spawner_position() -> Vector2:
	var rand = randi_range(0,1)
	match rand:
		0: return $Spawners/Spawner01/CollisionShape2D.position
		1: return $Spawners/Spawner02/CollisionShape2D.position
	# Retorno default
	return $Spawners/Spawner01/CollisionShape2D.position

func remove_camera_animation():
	$CameraBoss.free()
	$CameraAnimationPlayer.free()
	camera_killed = true
	game_controller.get_camera().enabled = true
	game_controller.get_camera().zoom = Vector2(2,2)
	$TileMap.set_layer_enabled(1, true)

func _on_move_to_boss_animation_finished():
	$CameraAnimationPlayer.play("back_to_player")

func on_enemy_die():
	enemies_on_screen-=1
	if number_mobs <= 0 and enemies_on_screen <= 0:
		all_enemies_die = true

func _on_entry_body_entered(body):
	if body.name == "Player" and not camera_killed:
		$Angelboss.init_boss()
		game_controller.get_camera().enabled = false
		$CameraAnimationPlayer.play("move_to_boss")
