extends Node3D

@export var player_count := 2
@export var player_spawns := [Vector2(5,5), Vector2(-5,5), Vector2(-5,-5), Vector2(5,-5)]

@export var trauma_reduction_rate := 1.0
@export var max_x := 4.0
@export var max_y := 10.0
@export var max_z := 10.0
@export var noise_speed := 50.0

var noise = FastNoiseLite.new()
var trauma := 0.0
var time := 0.0
var live_players := 0
var choosing := false

@onready var camera := $Camera3D
@onready var initial_rotation := camera.rotation_degrees as Vector3
@onready var player_scene := preload("res://Players/player.tscn")
@onready var upgrade_scene := preload("res://Upgrades/Choose_UI.tscn")

func _ready():
	Global.player_count = player_count
	instance_players()

func instance_players():
	for player in range(player_count):
		live_players += 1
		var player_instance = player_scene.instantiate()
		player_instance.player = player+1
		player_instance.position.x = player_spawns[player].x
		player_instance.position.z = player_spawns[player].y
		player_instance.position.y = 12
		add_child(player_instance)

func _process(delta):
	time += delta
	trauma = max(trauma - delta * trauma_reduction_rate, 0.0)
	
	camera.rotation_degrees.x = initial_rotation.x + max_x * get_shake_intensity() * get_noise_from_seed(0)
	camera.rotation_degrees.y = initial_rotation.y + max_y * get_shake_intensity() * get_noise_from_seed(1)
	camera.rotation_degrees.z = initial_rotation.z + max_z * get_shake_intensity() * get_noise_from_seed(2)
	
	if live_players == 1 and choosing == false:
		live_players -= 1
		for i in get_children():
			if i.is_in_group("player"):
				i.queue_free()
		choosing = true
		var upgrade_instance = upgrade_scene.instantiate()
		add_child(upgrade_instance)
		while choosing == true:
			await get_tree().create_timer(0.1).timeout
		instance_players()

func add_trauma(trauma_amount : float):
	trauma = clamp(trauma + trauma_amount, 0.0, 1.0)

func get_shake_intensity() -> float:
	return trauma * trauma

func get_noise_from_seed(_seed : int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(time * noise_speed)
