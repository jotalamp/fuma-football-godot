extends Node

@onready var controllers = get_tree().get_nodes_in_group("controllers")

var colors = [
	Color( 1.0, 0.0, 0.0 ),
	Color( 0.0, 0.0, 1.0 ),
	Color( 0.0, 1.0, 0.0 ),
	Color( 1.0, 1.0, 0.0 ),
	Color( 1.0, 0.0, 1.0 ),
	Color( 0.0, 1.0, 1.0 ),
	Color( 1.0, 1.0, 1.0 ),
	Color( 0.0, 0.0, 0.0 )
	]

#var controls = {"Shoot": [JOY_SONY_CIRCLE, JOY_R3],
#				"Reset": [JOY_SONY_TRIANGLE],
#				"SelectNextCamera": [JOY_DPAD_UP],
#				"CursorChange": [JOY_L],
#				"Dash": [JOY_R],}

func _ready():
	add_inputs()
	pass # Replace with function body.
	
func getController(id: int):
	return controllers[id-1]

func add_inputs():
	var _ev
	#for action in controls:
		#if not InputMap.has_action(action):
			#InputMap.add_action(action)
		#for button in controls[action]:
			##ev = InputEventKey.new()
			#ev = InputEventJoypadButton.new()
			##ev.scancode = key
			#ev.button_index = button
			#InputMap.action_add_event(action, ev)
			
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
