extends Node

@export var IDString = "C1_"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getAction(name1: String):
	return IDString + name1
	
func getActionShoot():
	return getAction("Shoot")
	
func getAxis(name1: String):
	var fullName = IDString + name1
	return Input.get_axis( fullName + "-", fullName + "+")
	
func getShootHeight():
	return 0.5 + 0.5 * getAxis("ShootHeight")
	
func isSuperCancelPressed():
	return Input.is_action_pressed( IDString + "R1" ) and Input.is_action_pressed( IDString + "R2" )


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
