
	
extends Camera3D

@onready var ball = $"/root/Root/Ball"
@export var player : RigidBody3D
@onready var targetPosition = ball.position

func _process(_delta):
	targetPosition = 0.97 * targetPosition + 0.03 * player.position
	position = targetPosition
	position.y = 5.0
	position.x += 15.0
	
	look_at( targetPosition, Vector3.UP )

	if Input.is_action_just_released("mouse_wheel_down"):
		fov += 1
	elif Input.is_action_just_released("mouse_wheel_up"):
		fov -= 1
		
	fov = clamp( fov, 5.0, 50.0 )
