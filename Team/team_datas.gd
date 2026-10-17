extends Node

var teamDatas

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getTeamData(id):
	teamDatas = get_tree().get_nodes_in_group("teamDatas")
	return teamDatas[id]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
