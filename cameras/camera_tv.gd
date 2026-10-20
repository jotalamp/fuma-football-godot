extends Camera3D

@onready var ball = $"/root/Root/Ball"
#onready var player = $"/root/Root/TeamHome/Player"
#@onready var player = get_tree().get_nodes_in_group("Player")[0]
@export var player : RigidBody3D
@onready var targetPosition = ball.position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	targetPosition.y = 2.0 + 0.1 * targetPosition.y
	targetPosition = 0.95 * targetPosition + 0.05 * ( 0.8 * ball.position + 0.3 * ball.linear_velocity + 0.2 * player.position )
	look_at( targetPosition, Vector3.UP )
	#var deltaVectorToBall = targetPosition - translation
	#var ballVelocity2D = Vector2( ball.linear_velocity.x, ball.linear_velocity.z )
	rotation_degrees.x = 0.8 * rotation_degrees.x - 0.2 * 22.0
	
	#if rotation_degrees.y > 165:
		#rotation_degrees.y = 165
	#elif rotation_degrees.y < 15:
		#rotation_degrees.y = 15
		
	#fov = 0.995 * fov + 0.005 * ( 5.0 + 4.0 * ( targetPosition - ball.translation ).length() )
	
	if fov > 25.0:
		fov = 25.0
		
	if Input.is_action_just_released("mouse_wheel_down"):
		fov += 1
	elif Input.is_action_just_released("mouse_wheel_up"):
		fov -= 1
