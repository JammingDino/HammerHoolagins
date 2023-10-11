extends Button

@export var stats = {
	"name":"Faster",
	"description":"You become slightly smaller, slightly redder and slightly faster."
}
@export var upagrade = "faster"
var for_player = 0

func _ready():
	$VBoxContainer/Name.text = stats["name"]
	$VBoxContainer/Description.text = stats["description"]
	self.size = $VBoxContainer.size


func _on_pressed():
	get_parent().get_parent().add_upgrade(stats["name"], for_player)
