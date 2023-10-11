extends CharacterBody3D

@export var player : int = 1

@onready var animater = $AnimationPlayer
@onready var life_bar = $"Body/3D_UI/Life"
@onready var lunge_timer = $Lunge_timer

const CONTROLLER_THRESHOLD = 0.3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var life : float = 10.0
var can_primary : bool = true
var lurching : bool = false
var swing : int = 1

var stats = {}

func _ready():
	if player == 1:
		stats = Global.player_1_stats
	elif player == 2:
		stats = Global.player_2_stats
	elif player == 3:
		stats = Global.player_3_stats
	elif player == 4:
		stats = Global.player_4_stats
		
	scale = Vector3(stats["size"], stats["size"], stats["size"])
	life = stats["max_life"]

func _damage(amount):
	get_parent().add_trauma(amount/stats["max_life"])
	life -= amount
	life_bar.scale.x = life/stats["max_life"]
	if life < 0.05:
		print("Player "+str(player)+" Dead")
		get_parent().live_players -= 1
		queue_free()

func _physics_process(delta):
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Movement
	var move_direction = Vector3(Input.get_joy_axis(player-1, JOY_AXIS_LEFT_X), 0, Input.get_joy_axis(player-1, JOY_AXIS_LEFT_Y))
	var used_directions = Vector2(0,0)
	
	if move_direction:
		if move_direction.x > CONTROLLER_THRESHOLD or move_direction.x < -CONTROLLER_THRESHOLD:
			velocity.x += move_direction.x * stats["speed"]
			used_directions.x = 1
		if move_direction.z > CONTROLLER_THRESHOLD or move_direction.z < -CONTROLLER_THRESHOLD:
			velocity.z += move_direction.z * stats["speed"]
			used_directions.y = 1
	
	if velocity.x > stats["speed"]*2 and lurching == false:
		velocity.x = stats["speed"]*2
	if velocity.x < stats["speed"]*-2 and lurching == false:
		velocity.x = stats["speed"]*-2
	if velocity.z > stats["speed"]*2 and lurching == false:
		velocity.z = stats["speed"]*2
	if velocity.z < stats["speed"]*-2 and lurching == false:
		velocity.z = stats["speed"]*-2
	
	if used_directions.x != 1:
		velocity.x = move_toward(velocity.x, 0, stats["speed"]/5)
	if used_directions.y != 1:
		velocity.z = move_toward(velocity.z, 0, stats["speed"]/5)
	
	move_and_slide()
	
	# Handle Animation
	
	if animater.current_animation != "smack" and animater.current_animation != "swing":
		animater.speed_scale = 1
		if used_directions.x + used_directions.y == 0:
			animater.play("idle")
		else:
			animater.play("walk")
	else:
		animater.speed_scale = 1.2/stats["attack_speed"]
	
	# Hangle Rotation
	var look_direction = Vector3(-Input.get_joy_axis(player-1, JOY_AXIS_RIGHT_X),0, -Input.get_joy_axis(player-1, JOY_AXIS_RIGHT_Y))
	var looked_directions = Vector2(0,0)
	if look_direction:
			if look_direction.x > CONTROLLER_THRESHOLD or look_direction.x < -CONTROLLER_THRESHOLD:
				looked_directions.x = 1
			if look_direction.y > CONTROLLER_THRESHOLD or look_direction.y < -CONTROLLER_THRESHOLD:
				looked_directions.y = 1
	
	if looked_directions.x != 0 or looked_directions.y != 0:
		look_direction = look_direction + position
		look_at(look_direction, Vector3.UP)
	#Handle attacks
	if player == 1:
		if 2 in stats["special"]:
			if Input.is_action_pressed("p1_r_trigger") and can_primary:
				animater.speed_scale = stats["attack_speed"]
				if swing == 1:
					animater.play("swing")
					swing = 2
				elif swing == 2:
					animater.play_backwards("swing")
					swing = 1
				if 1 in stats["special"]:
					lurching = true
					velocity = global_transform.basis.z.normalized() * 30
					velocity.y = 0
					lunge_timer.start()
				can_primary = false
				await get_tree().create_timer((animater.get_animation("smack").length*stats["attack_speed"])+0.1).timeout
				can_primary = true
				
		else:
			if Input.is_action_pressed("p1_r_trigger") and can_primary:
				animater.speed_scale = stats["attack_speed"]
				animater.play("smack")
				if 1 in stats["special"]:
					lurching = true
					velocity = global_transform.basis.z.normalized() * 30
					velocity.y = 0
					lunge_timer.start()
				can_primary = false
				await get_tree().create_timer((animater.get_animation("smack").length*stats["attack_speed"])+0.1).timeout
				can_primary = true
	elif player == 2:
		if 2 in stats["special"]:
			if Input.is_action_pressed("p2_r_trigger") and can_primary:
				animater.speed_scale = stats["attack_speed"]
				if swing == 1:
					animater.play("swing")
					swing = 2
				elif swing == 2:
					animater.play_backwards("swing")
					swing = 1
				if 1 in stats["special"]:
					lurching = true
					velocity = global_transform.basis.z.normalized() * 30
					velocity.y = 0
					lunge_timer.start()
				can_primary = false
				await get_tree().create_timer((animater.get_animation("smack").length*stats["attack_speed"])+0.1).timeout
				can_primary = true
		else:
			if Input.is_action_just_pressed("p2_r_trigger"):
				animater.speed_scale = stats["attack_speed"]
				animater.play("smack")
				if 1 in stats["special"]:
					lurching = true
					velocity = global_transform.basis.z.normalized() * 30
					velocity.y = 0
					lunge_timer.start()
				can_primary = false
				await get_tree().create_timer((animater.get_animation("smack").length*stats["attack_speed"])+0.1).timeout
				can_primary = true


func _on_attack_box_body_entered(body):
	if body.name != self.name and body.is_in_group("player"):
		body._damage(stats["damage"])


func _on_lunge_timer_timeout():
	lurching = false
