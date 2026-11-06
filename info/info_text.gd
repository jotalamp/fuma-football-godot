extends Label

@export var player : RigidBody3D
var maxBallSpeed = 0.0
var maxBallRotationSpeed = 0.0
const revPerSecondFactor = 1.0 / ( 2 * PI ) 
@onready var cameras = $"/root/Root/Cameras"

func _process(_delta: float) -> void:
	
	#var player = $"/root/Root/TeamHome/Player_01"
	var playerSpeed = player.linear_velocity.length()
	
	var ball = $"/root/Root/Ball"
	var ballSpeed = 3.6 * ball.linear_velocity.length()
	var ballRotationSpeed = ball.angular_velocity.length() * revPerSecondFactor
	
	if ballSpeed > maxBallSpeed:
		maxBallSpeed = ballSpeed
	
	if ballRotationSpeed > maxBallRotationSpeed:
		maxBallRotationSpeed = ballRotationSpeed
		
	#var camera = $"/root/Root/CameraTV"
		
	#var screen_pos = camera.unproject_position(player.translation)
	
	#rect_position = screen_pos
	
	set_text(
		"FPS: " + str(Engine.get_frames_per_second()) + 
		"\n\n\n\n" +
		"\nPlayer speed: " + String("%4.1f" % playerSpeed) + " m/s" + 
		"\nBall speed: " + String("%4.1f" % ballSpeed) + " km/h" +
		"\nMax ball speed: " + String("%4.1f" % maxBallSpeed) + " km/h" +
		"\nBall rotation speed: " + String("%4.1f" % ballRotationSpeed) +
		"\nMax ball rotation speed: " + String("%4.1f" % maxBallRotationSpeed) + " rev/s" +
		"\nCamera: " + cameras.getCurrentCameraName()
	)
