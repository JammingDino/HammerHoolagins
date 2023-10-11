extends Node2D

@onready var card = preload("res://Upgrades/card.tscn")
var chosen = false

var upgrades = {
	"Faster" : {
		"name":"Faster",
		"description":"You become slightly smaller, and slightly faster."
	},
	"Healthier" : {
		"name":"Healthier",
		"description":"You become slightly bigger, and your life slightly increases."
	},
	"Stronger" : {
		"name":"Stronger",
		"description":"You do more damage"
	},
	"Quick_Attack": {
		"name":"Quick Attack",
		"description":"Your attack speed is increased."
	},
	"Tank": {
		"name": "Tank",
		"description":"Your max life is much higher and you are much slower."
	},
	"Lunge":{
		"name": "Lunge",
		"description":"You lunge forward when you attack"
	},
	"Swing":{
		"name": "Swing",
		"description":"Turns your main attack into a swing rather than a smack."
	}
}

func add_upgrade(upgrade, player):
	print(upgrade)
	if player == 1:
		if upgrade == "Faster":
			Global.player_1_stats["speed"] += 2.5
			Global.player_1_stats["size"] = (Global.player_1_stats["size"]*0.01) * 85
		elif upgrade == "Healthier":
			Global.player_1_stats["max_life"] += 5.0
			Global.player_1_stats["size"] = (Global.player_1_stats["size"]*0.01) * 115
		elif upgrade == "Quick Attack":
			Global.player_1_stats["attack_speed"] = (Global.player_1_stats["attack_speed"]*0.01) * 75
		elif upgrade == "Tank":
			Global.player_1_stats["max_life"] = (Global.player_1_stats["max_life"]*0.01) * 200
			Global.player_1_stats["speed"] = (Global.player_1_stats["speed"]*0.01) * 60
			Global.player_1_stats["size"] = (Global.player_1_stats["size"]*0.01) * 200
		elif upgrade == "Lunge":
			Global.player_1_stats["special"].append(1)
		elif upgrade == "Swing":
			Global.player_1_stats["special"].append(2)
		elif upgrade == "Stronger":
			Global.player_1_stats["damage"] = (Global.player_1_stats["damage"]*0.01) * 150
		
	elif player == 2:
		if upgrade == "Faster":
			Global.player_2_stats["speed"] += 2.5
			Global.player_2_stats["size"] = (Global.player_2_stats["size"]*0.01) * 85
		elif upgrade == "Healthier":
			Global.player_2_stats["max_life"] += 5.0
			Global.player_2_stats["size"] = (Global.player_2_stats["size"]*0.01) * 115
		elif upgrade == "Quick Attack":
			Global.player_2_stats["attack_speed"] = (Global.player_2_stats["attack_speed"]*0.01) * 75
		elif upgrade == "Tank":
			Global.player_2_stats["max_life"] = (Global.player_2_stats["max_life"]*0.01) * 200
			Global.player_2_stats["speed"] = (Global.player_2_stats["speed"]*0.01) * 60
			Global.player_2_stats["size"] = (Global.player_2_stats["size"]*0.01) * 200
		elif upgrade == "Lunge":
			Global.player_2_stats["special"].append(1)
		elif upgrade == "Swing":
			Global.player_2_stats["special"].append(2)
		elif upgrade == "Stronger":
			Global.player_2_stats["damage"] = (Global.player_2_stats["damage"]*0.01) * 150
	chosen = true

func _ready():
	for i in range(Global.player_count):
		$Label.text = "Player "+str(i+1)
		for j in range(Global.card_count):
			new_card(i+1)
		
		while chosen == false:
			await get_tree().create_timer(0.1).timeout
		
		for child in $Card_Holder.get_children():
			child.queue_free()
		
		chosen = false
	get_parent().choosing = false
	queue_free()

func new_card(player):
	var card_instance = card.instantiate()
	card_instance.for_player = player
	randomize()
	card_instance.stats = upgrades.values()[randi_range(0,len(upgrades)-1)]
	$Card_Holder.add_child(card_instance)
