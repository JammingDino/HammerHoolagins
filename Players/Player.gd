extends CharacterBody3D

@export var player : int = 1

@onready var animater = $AnimationPlayer
@onready var life_bar = $"Body/3D_UI/Life"
@onready var lunge_timer = $Lunge_timer
@onready var rotation_arrow = $Rotation

const CONTROLLER_THRESHOLD = 0.3

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var life : float = 10.0
var attack_button = ""
var can_primary : bool = true
var lurching : bool = false
var swing : int = 1
var dot_fire_time = 0
var dot_poison_time = 0

var stats = {}

func _ready():
	stats = Global.player_stats["player_"+str(player)+"_stats"]
	if player == 1:
		attack_button = "p1_attack"
	elif player == 2:
		attack_button = "p2_r_trigger"
	elif player == 3:
		attack_button = "p3_r_trigger"
	elif player == 4:
		attack_button = "p3_r_trigger"
		
	scale = Vector3(stats["size"], stats["size"], stats["size"])
	life = stats["max_life"]
	life_bar.scale.x = life/stats["max_life"]

func _damage(amount):
	get_parent().add_trauma(amount/stats["max_life"])
	life -= amount
	life_bar.scale.x = life/stats["max_life"]
	if life < 0.05:
		print("Player "+str(player)+" Dead")
		get_parent().live_players -= 1
		queue_free()

func _physics_process(delta):
	
	# Add the gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle Movement
	var move_direction = Vector3()
	if player == 1:
		move_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		move_direction = Vector3(move_direction.x, 0, move_direction.y)
	else:
		move_direction = Vector3(Input.get_joy_axis(player-2, JOY_AXIS_LEFT_X), 0, Input.get_joy_axis(player-2, JOY_AXIS_LEFT_Y))
	var used_directions = Vector2(0,0)
	
	if move_direction:
		if velocity.x < stats["speed"]*2 and velocity.x > stats["speed"]*-2 and lurching == false:
			if move_direction.x > CONTROLLER_THRESHOLD or move_direction.x < -CONTROLLER_THRESHOLD:
				velocity.x += move_direction.x * stats["speed"]
				used_directions.x = 1
		if velocity.z < stats["speed"]*2 and velocity.z > stats["speed"]*-2 and lurching == false:
			if move_direction.z > CONTROLLER_THRESHOLD or move_direction.z < -CONTROLLER_THRESHOLD:
				velocity.z += move_direction.z * stats["speed"]
				used_directions.y = 1
	
	velocity.x = move_toward(velocity.x, 0, stats["speed"]/5)
	velocity.z = move_toward(velocity.z, 0, stats["speed"]/5)
	
	# Hangle Rotation
	var look_direction = Vector3()
	if player == 1:
		look_direction = Input.get_vector("look_left", "look_right", "look_down", "look_up")
		look_direction = Vector3(look_direction.x, 0, look_direction.y)
	else:
		look_direction = Vector3(Input.get_joy_axis(player-2, JOY_AXIS_RIGHT_X),0, -Input.get_joy_axis(player-2, JOY_AXIS_RIGHT_Y))
	var looked_directions = Vector2(0,0)
	if look_direction:
			if look_direction.x > CONTROLLER_THRESHOLD or look_direction.x < -CONTROLLER_THRESHOLD:
				looked_directions.x = 1
			if look_direction.z > CONTROLLER_THRESHOLD or look_direction.z < -CONTROLLER_THRESHOLD:
				looked_directions.y = 1
	
	if looked_directions == Vector2(0,0) and (velocity.x != 0 or velocity.z != 0):
		look_direction = velocity.normalized()
		look_direction.z = look_direction.z * -1
		looked_directions.x = 1
	
	if looked_directions.x != 0 or looked_directions.y != 0:
		rotation.y = lerp_angle(rotation.y, deg_to_rad(90.0) + Vector2(look_direction.x, look_direction.z).angle(), delta * stats["spin_speed"])
	
	move_and_slide()
	
	# Handle Animation
	
	if animater.current_animation != "smack" and animater.current_animation != "swing":
		animater.speed_scale = 1
		if velocity.x + velocity.z != 0:
			animater.play("walk")
		else:
			animater.play("idle")
	else:
		animater.speed_scale = 1.2/stats["attack_speed"]
	
	#Handle attacks
	if 2 in stats["special"]:
		if Input.is_action_pressed(attack_button) and can_primary:
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
			await get_tree().create_timer((animater.get_animation("smack").length*stats["attack_speed"])+0.08*stats["attack_speed"]).timeout
			can_primary = true
			
	else:
		if Input.is_action_pressed(attack_button) and can_primary:
			animater.speed_scale = stats["attack_speed"]
			animater.play("smack")
			if 1 in stats["special"]:
				lurching = true
				velocity = global_transform.basis.z.normalized() * 30
				velocity.y = 0
				lunge_timer.start()
			can_primary = false
			await get_tree().create_timer((animater.get_animation("smack").length*stats["attack_speed"])+0.08*stats["attack_speed"]).timeout
			can_primary = true

func _process(_delta):
	if dot_poison_time > 0:
		$Body/Particles/poison_particles.emitting = true
	else:
		$Body/Particles/poison_particles.emitting = false
	
	if dot_fire_time > 0:
		$Body/Particles/Flame.emitting = true
		$Body/Particles/Smoke.emitting = true
		$Body/Particles/Embers.emitting = true
	else:
		$Body/Particles/Flame.emitting = false
		$Body/Particles/Smoke.emitting = false
		$Body/Particles/Embers.emitting = false

func _on_attack_box_body_entered(body):
	if body.name != self.name and body.is_in_group("player"):
		if 4 in Global.player_stats["player_"+str(body.player)+"_stats"]["special"]: #Thorns
			_damage(stats["damage"]/2)
		if 5 in Global.player_stats["player_"+str(body.player)+"_stats"]["special"]: #Knockback
			lurching = true
			velocity = (self.position - body.position).normalized() * 20
			lunge_timer.start()
		if 3 in stats["special"]: #Vamperic
			self._damage(-stats["damage"]/2)
		if 6 in stats["special"]: #Poison
			body.dot_poison_time = 6
		if 7 in stats["special"]: #Poison
			body.dot_fire_time = 12
		
		body._damage(stats["damage"])


func _on_lunge_timer_timeout():
	lurching = false

func _on_damage_over_time_timer_timeout():
	if dot_fire_time > 0:
		dot_fire_time -= 1
		_damage(0.5)
	if dot_poison_time > 0:
		dot_poison_time -= 1
		_damage(1)


func _on_fire_spread_body_entered(body):
	if body.name != self.name and body.is_in_group("player") and dot_fire_time > 0:
		body.dot_fire_time = dot_fire_time
