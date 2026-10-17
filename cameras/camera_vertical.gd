extends Camera3D

@onready var ball = $"/root/Root/Ball"
@onready var player = $"../".player
@onready var targetPosition = ball.position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	targetPosition = ball.position
	position = targetPosition
	position.y = 5.0
	position.z += 15.0
	#targetPosition.y = 2.0 + 0.1 * targetPosition.y
	#targetPosition = 0.95 * targetPosition + 0.05 * ( 0.8 * ball.translation + 0.3 * ball.linear_velocity + 0.2 * player.translation )
	look_at( targetPosition, Vector3.UP )
	#var deltaVectorToBall = targetPosition - translation
	#var ballVelocity2D = Vector2( ball.linear_velocity.x, ball.linear_velocity.z )
	#rotation_degrees.x = 0.8 * rotation_degrees.x - 0.2 * 22.0
	
	#if rotation_degrees.y > 165:
		#rotation_degrees.y = 165
	#elif rotation_degrees.y < 15:
		#rotation_degrees.y = 15
		
	fov = 0.995 * fov + 0.005 * ( 5.0 + 4.0 * ( targetPosition - ball.position ).length() )
	
	if fov > 20.0:
		fov = 20.0
		
	if Input.is_action_just_released("mouse_wheel_down"):
		fov += 1
	elif Input.is_action_just_released("mouse_wheel_up"):
		fov -= 1
		
	fov = 50.0
