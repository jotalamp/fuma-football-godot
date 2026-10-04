extends RigidBody3D

var _initial_transform
var shoot_power = 30.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_initial_transform = self.global_transform
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player_direction = Vector2()

	if Input.is_action_just_released("shoot"):
		apply_central_impulse( 
			shoot_power * Vector3(0.01,0.05,0.2) );
		apply_torque_impulse(Vector3(0.1,0,0))

func _integrate_forces(state):
	if Input.is_action_pressed("reset"):
		state.set_transform(_initial_transform)
		linear_velocity = Vector3()
