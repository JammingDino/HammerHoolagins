extends Node2D

@onready var card = preload("res://Upgrades/card.tscn")
var chosen = false
var current_player = 0
var selection_angle = 0
var attack_button = ""
const CONTROLLER_THRESHOLD = 0.3

var upgrades = {
	"Faster" : {
		"name":"Faster",
		"description":"You become slightly smaller, and slightly faster"
	},
	"Healthier" : {
		"name":"Healthier",
		"description":"You become slightly bigger, and your life slightly increases"
	},
	"Stronger" : {
		"name":"Stronger",
		"description":"You do more damage"
	},
	"Quick_Attack": {
		"name":"Quick Attack",
		"description":"Your attack speed is increased"
	},
	"Tank": {
		"name": "Tank",
		"description":"Your max life is much higher and you are much slower"
	},
	"Lunge":{
		"name": "Lunge",
		"description":"You lunge forward when you attack"
	},
	"Swing":{
		"name": "Swing",
		"description":"Turns your main attack into a swing rather than a smack"
	},
	"Sniper":{
		"name":"Sniper",
		"description":"Way more damage, way lower attack speed"
	},
	"Vamperic":{
		"name":"Vamperic",
		"description":"Damaging opponenets gains you life"
	},
	"Thorns":{
		"name":"Thorns",
		"description":"Whenever you take damage, oppenets take half that much damage"
	},
	"Sabotage":{
		"name":"Sabotage",
		"description":"All oppoenets stats are lowered by 10%"
	},
	"Posionous":{
		"name":"Posionous",
		"description":"Your attacks apply a damage over time effect. 1 d/s for 3 seconds"
	},
	"Flaming Hammer":{ ## Still Needs to Be Made
		"name":"Flaming Hammer",
		"description":"Your attacks apply a damage over time effect that can spread to other players. 0.5 d/s for 6 seconds"
	},
	"Shockwave":{ ## Still Needs to Be Made
		"name":"Shockwave",
		"description":"Your attacks cause a shockwave"
	},
	"Knockback":{
		"name":"Knockback",
		"description":"Whoever attacks you gets knocked back"
	}
}

func add_upgrade(upgrade, player):
	print(upgrade)
	var player_string = ""
	player_string = "player_"+str(player)+"_stats"
	if upgrade == "Faster":
		Global.player_stats[player_string]["speed"] += 2.5
		Global.player_stats[player_string]["size"] = (Global.player_stats[player_string]["size"] *0.01) * 85
	elif upgrade == "Healthier":
		Global.player_stats[player_string]["max_life"] += 5.0
		Global.player_stats[player_string]["size"] = (Global.player_stats[player_string]["size"] *0.01) * 115
	elif upgrade == "Quick Attack":
		Global.player_stats[player_string]["attack_speed"] = (Global.player_stats[player_string]["attack_speed"] *0.01) * 75
	elif upgrade == "Tank":
		Global.player_stats[player_string]["max_life"] = (Global.player_stats[player_string]["max_life"] *0.01) * 200
		Global.player_stats[player_string]["speed"] = (Global.player_stats[player_string]["speed"] *0.01) * 60
		Global.player_stats[player_string]["size"] = (Global.player_stats[player_string]["size"] *0.01) * 200
	elif upgrade == "Lunge":
		Global.player_stats[player_string]["special"].append(1)
	elif upgrade == "Swing":
		Global.player_stats[player_string]["special"].append(2)
	elif upgrade == "Stronger":
		Global.player_stats[player_string]["damage"] = (Global.player_stats[player_string]["damage"] *0.01) * 150
	elif upgrade == "Sniper":
		Global.player_stats[player_string]["damage"] = (Global.player_stats[player_string]["damage"] *0.01) * 200
		Global.player_stats[player_string]["attack_speed"] = (Global.player_stats[player_string]["attack_speed"] *0.01) * 150
	elif upgrade == "Vamperic":
		Global.player_stats[player_string]["special"].append(3)
	elif upgrade == "Sabotage":
		for key in Global.player_stats:
			if key != player_string:
				Global.player_stats[key]["size"] = (Global.player_stats[key]["size"]*0.01) * 85
				Global.player_stats[key]["damage"] = (Global.player_stats[key]["damage"]*0.01) * 85
				Global.player_stats[key]["attack_speed"] = (Global.player_stats[key]["attack_speed"]*0.01) * 115
				Global.player_stats[key]["max_life"] = (Global.player_stats[key]["max_life"]*0.01) * 85
				Global.player_stats[key]["speed"] = (Global.player_stats[key]["speed"]*0.01) * 85
	elif upgrade == "Thorns":
		Global.player_stats[player_string]["special"].append(4)
	elif upgrade == "Knockback":
		Global.player_stats[player_string]["special"].append(5)
	elif upgrade == "Posionous":
		Global.player_stats[player_string]["special"].append(6)
	elif upgrade == "Flaming Hammer":
		Global.player_stats[player_string]["special"].append(7)
	
	chosen = true

func _ready():
	for i in range(Global.player_count):
		current_player = i+1
		$Label.text = "Player "+str(i+1)
		for j in range(Global.card_count):
			new_card(i+1, j)
		
		while chosen == false:
			await get_tree().create_timer(0.1).timeout
		
		for child in $Node2D.get_children():
			child.queue_free()
		
		chosen = false
	get_parent().choosing = false
	queue_free()

func _process(delta):
	
	if current_player == 1:
		attack_button = "p1_attack"
	elif current_player == 2:
		attack_button = "p2_r_trigger"
	elif current_player == 3:
		attack_button = "p3_r_trigger"
	elif current_player == 4:
		attack_button = "p3_r_trigger"
	
	# Hangle Rotation
	var look_direction = Vector3()
	if current_player == 1:
		look_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		look_direction = Vector3(look_direction.x, 0, look_direction.y)
	else:
		look_direction = Vector3(Input.get_joy_axis(current_player-2, JOY_AXIS_LEFT_X),0, Input.get_joy_axis(current_player-2, JOY_AXIS_LEFT_Y))
	var looked_directions = Vector2(0,0)
	if look_direction:
			if look_direction.x > CONTROLLER_THRESHOLD or look_direction.x < -CONTROLLER_THRESHOLD:
				looked_directions.x = 1
			if look_direction.z > CONTROLLER_THRESHOLD or look_direction.z < -CONTROLLER_THRESHOLD:
				looked_directions.y = 1
	
	if looked_directions.x != 0 or looked_directions.y != 0:
		selection_angle = lerp_angle(selection_angle, deg_to_rad(90.0) + Vector2(look_direction.x, look_direction.z).angle(), delta * 10)
	selection_angle = fmod(selection_angle+6.28319, 6.28319)
	var usable_selection_angle = snappedf(selection_angle, 0.5)
	for i in $Node2D.get_children():
		i.get_child(0).release_focus()
	if usable_selection_angle == 0 or usable_selection_angle == 6.5:
		$Node2D.get_child(0).get_child(0).grab_focus()
		if Input.is_action_just_pressed(attack_button):
			$Node2D.get_child(0).get_child(0).emit_signal("pressed")
	if usable_selection_angle == 1 or usable_selection_angle == 0.5:
		$Node2D.get_child(1).get_child(0).grab_focus()
		if Input.is_action_just_pressed(attack_button):
			$Node2D.get_child(1).get_child(0).emit_signal("pressed")
	if usable_selection_angle == 1.5 or usable_selection_angle == 2:
		$Node2D.get_child(2).get_child(0).grab_focus()
		if Input.is_action_just_pressed(attack_button):
			$Node2D.get_child(2).get_child(0).emit_signal("pressed")
	if usable_selection_angle == 2.5:
		$Node2D.get_child(3).get_child(0).grab_focus()
		if Input.is_action_just_pressed(attack_button):
			$Node2D.get_child(3).get_child(0).emit_signal("pressed")
	if usable_selection_angle == 3 or usable_selection_angle == 3.5:
		$Node2D.get_child(4).get_child(0).grab_focus()
		if Input.is_action_just_pressed(attack_button):
			$Node2D.get_child(4).get_child(0).emit_signal("pressed")
	if usable_selection_angle == 4:
		$Node2D.get_child(5).get_child(0).grab_focus()
		if Input.is_action_just_pressed(attack_button):
			$Node2D.get_child(5).get_child(0).emit_signal("pressed")
	if usable_selection_angle == 4.5 or usable_selection_angle == 5:
		$Node2D.get_child(6).get_child(0).grab_focus()
		if Input.is_action_just_pressed(attack_button):
			$Node2D.get_child(6).get_child(0).emit_signal("pressed")
	if usable_selection_angle == 5.5 or usable_selection_angle == 6:
		$Node2D.get_child(7).get_child(0).grab_focus()
		if Input.is_action_just_pressed(attack_button):
			$Node2D.get_child(7).get_child(0).emit_signal("pressed")


func new_card(player, card_count):
	var card_instance = card.instantiate()
	card_instance.for_player = player
	randomize()
	card_instance.stats = upgrades.values()[randi_range(0,len(upgrades)-1)]
	card_instance.rotation = deg_to_rad(card_count * 45)
	$Node2D.add_child(card_instance)
