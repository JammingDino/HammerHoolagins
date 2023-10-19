extends Node2D

@export var stats = {
	"name":"Faster",
	"description":"You become slightly smaller, slightly redder and slightly faster."
}
@export var upagrade = "faster"
var for_player = 0

func _ready():
	$Button/VBoxContainer/Name.text = stats["name"]
	$Button/VBoxContainer/Description.text = stats["description"]
	$Button.size = $Button/VBoxContainer.size

func _on_button_pressed():
	get_parent().get_parent().add_upgrade(stats["name"], for_player)
