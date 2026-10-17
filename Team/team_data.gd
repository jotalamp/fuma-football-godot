extends Node

@export var shortName = "RFC"
@export var color_1 = Color()
@export var color_2 = Color()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getTeamColor():
	return color_1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
