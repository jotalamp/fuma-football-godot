extends Node

@export var id = 0
@onready var teamDatas = $"/root/Root/TeamDatas"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getTeamData():
	var teamDatas = $"/root/Root/TeamDatas"
	return teamDatas.getTeamData(id)
	#pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
