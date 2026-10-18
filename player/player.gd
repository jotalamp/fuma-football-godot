extends RigidBody3D
class_name Player

@export var playerID = 0
@export var controllerIDNumber = 0

@export var maxSpeed = 0.6 * 10.0 # m/s
@export var jogAnimationSpeed = 0.6
var maxForce = 5.0 * mass * 6.0 # m/s2 = N
@export var maxTurningTorque = 11000.0
@export var shootPowerRiseSpeed = 0.05

var direction = Vector2()
var shootDirection = Vector3()
var animationPlayer
var inputDirection2D = Vector2()
var inputDirection3D = Vector3()
var dribblePosition = Vector3()
var verticalCamera = false
var delta_position = Vector2()

@onready var teamDatas = $"/root/Root/TeamDatas"
@onready var cameras = $"/root/Root/Cameras"
@onready var players = $"/root/Root/Players"
@onready var ball = $"/root/Root/Ball"
#@onready var rightFoot = $"./Animations/RightFoot"
@onready var shootHeightBar = $"./PowerBar/ShootHeightBar"
@onready var shootPowerBar = $"./PowerBar/ShootPowerBar"
@onready var arrow = $"./Arrow"

@onready var controllers = $"/root/Root/Controllers"
@onready var team = $"../"
@onready var radar = $"/root/Root/Radar"

@export var currentCamera : Camera3D

enum State { STATE_IDLE, STATE_DRIBBLE, STATE_PREPARE_TO_KICK, STATE_KICK }

var currentState = State.STATE_IDLE

# Called when the node enters the scene tree for the first time.
func _ready():
	radar.addPlayerDot()
	
	var mesh = $"./Animations/Armature/Skeleton3D/Ch38_Shirt"
	var mat = mesh.get_active_material(0).duplicate(true)
	
	mat.albedo_color = getTeamColor()
		
	#mesh.set_surface_override_material(0, mat)
	
	animationPlayer = $"./Animations/AnimationPlayer"
	
	#var animations = ['Jog_02','Kick_05','Idle_01']
	
	#animationPlayer.playback_speed = 20.0
	
	#var animation = animationPlayer.get_animation('Jog_02')	
	#animation.loop = true
	
	#for animation in animations:
		#animation = animationPlayer.get_animation(animation)	
		#animation.loop = true
		
	#arrow.modulate = getTeamColor()
	
	direction = -get_global_transform().basis.x

func getTeamId():
	return team.id
	
func getTeamData():
	return team.getTeamData()

func controller():
	return controllers.controllers[controllerIDNumber-1]

func getControllerIDString():
	return "C" + str(controllerIDNumber) + "_"

func getAxis(name1: String):
	var fullName = getControllerIDString() + name1
	return Input.get_axis( fullName + "-", fullName + "+")

func getTeamColor():
	#return getTeamData().getTeamColor()
	return Color.RED

func getShootHeightBarValue():
	return shootHeightBar.value
	
func getShootPowerBarValue():
	return shootPowerBar.value
	
func getShootCurveFactor():
	return getAxis("Curve")
	#return Input.get_axis( getControllerIDString() + "Curve-", getControllerIDString() + "Curve+")
	#return Input.get_action_strength(controllerID + "_Curve+") - Input.get_action_strength(controllerID + "_Curve-")
	
func getShootSpinFactor():
	#var spin = Input.get_axis( controllerID + "_TopSpin", controllerID + "_BackSpin")
	var spin = getAxis("Spin")
	if spin < 0.0:
		return spin
	else:
		return 2.0 * spin
	#return Input.get_action_	#return Input.get_action_strength(controllerID + "_TopSpin") - Input.get_action_strength(controllerID + "_BackSpin")
	
func shooted():
	shootPowerBar.value = 0

func distanceToBall():
	return (position - ball.position).length()

func rightFootPosition():
	return position #+ rightFoot.position



func _deltaAngle(current: Vector2, target: Vector2):
	var targetAngle = atan2( target.y, target.x )
	
	if( targetAngle < 0.0 ):
		targetAngle += 2.0 * PI
	
	var currentAngle = atan2( current.y, current.x ) + PI
	var deltaAngle = targetAngle - currentAngle
	
	if deltaAngle > PI:
		deltaAngle -= 2.0 * PI
	elif deltaAngle < -PI:
		deltaAngle += 2.0 * PI
		
	return deltaAngle

func isNearestPlayerToBall():
	if playerID == players.idOfNearestPlayerToBall():
		return true
	else:
		return false
	
func _physics_process(delta):
	
	# Game controller
	var input = Vector2( Input.get_joy_axis(controllerIDNumber-1, JOY_AXIS_LEFT_X), -Input.get_joy_axis(controllerIDNumber-1, JOY_AXIS_LEFT_Y) )
	
	# Keyboard
	if playerID == 1:
		if Input.is_action_pressed("ui_up"):
			input = Vector2( 0.0, +1.0 )
		elif Input.is_action_pressed("ui_down"):
			input = Vector2( 0.0, -1.0 )
			
		if Input.is_action_pressed("ui_left"):
			input += Vector2( -1.0, 0.0 )
		elif Input.is_action_pressed("ui_right"):
			input += Vector2( +1.0, 0.0 )
		
	var cameraForward = currentCamera.transform.basis.z.normalized()
	
	inputDirection3D = -cameraForward * input.y - cameraForward.cross(Vector3.UP) * input.x
	inputDirection2D =  Vector2( -inputDirection3D.z, -inputDirection3D.x )
	
	direction = -get_global_transform().basis.x
	
	if inputDirection2D.length() < 0.3:
		inputDirection2D = Vector2.ZERO
		return
	
	input = inputDirection2D
	
	var inputAngle = atan2( input.y, input.x )
	$"./Arrow".rotation = Vector3( $"./Arrow".rotation.x, inputAngle - rotation.y, $"./Arrow".rotation.z )
		
	# AI
	var deltaPosition3D = ball.position - position - 1.0 * inputDirection3D
	var deltaPosition2D = Vector2(-deltaPosition3D.z,-deltaPosition3D.x)
	
	if (
			isNearestPlayerToBall() 
			and abs( ball.position.z ) < 50.0
			#and not controller().isSuperCancelPressed()
			and deltaPosition2D.length() < 0.01
	):
			currentState = State.STATE_DRIBBLE
			input = 0.05 * deltaPosition2D * ( inputDirection2D.length() + 0.42 )
		
	if input.length() > 1.0:
		input = input.normalized()
		
	if deltaPosition2D.length() < 0.3 and input.length() < 0.2:
		input = Vector2.ZERO
		
	direction = -get_global_transform().basis.x
	
	var targetAngle = atan2( input.y, input.x )
	
	if( targetAngle < 0.0 ):
		targetAngle += 2.0 * PI
	
	var currentAngle = rotation.y + PI
	var deltaAngle = targetAngle - currentAngle
	
	if deltaAngle > PI:
		deltaAngle -= 2.0 * PI
	elif deltaAngle < -PI:
		deltaAngle += 2.0 * PI
	
	apply_torque( mass * delta * maxTurningTorque * deltaAngle * Vector3.UP / ( linear_velocity.length() + 1.0 ) );
	
	if deltaAngle > 0.5 * PI:
		#pass
		apply_central_force( -abs(deltaAngle) * delta * mass * maxForce * input.length() * Vector3( sin( rotation.y ), 0.0, cos( rotation.y ) ));
	
	if( linear_velocity.length() < maxSpeed and input.length() > 0.3):
		#pass
		apply_central_force( 5.0 * delta * mass * maxForce * input.length() * Vector3( sin( rotation.y ), 0.0, cos( rotation.y ) ));
		#apply_central_force(input.length()*Vector3( sin( rotation.y ), 0.0, cos( rotation.y ) ))
	
	var tf = get_global_transform()
	var vel = get_linear_velocity()
	var right_normal = tf.basis.x
	#get the orthogonal velocity vector
	var right_vel = right_normal.dot(vel) * right_normal
	apply_central_impulse( - 0.08 * mass * right_vel );
	
	delta_position = $"/root/Root/Ball".position - (position - 1.0 * Vector3(direction.normalized().y,0.0,direction.normalized().x))
	
	#if delta_position.length() < 4.0:
		
		#var direction_to_get_ball = delta_position
		#var direction_to_get_ball_2 = right_normal.dot(direction_to_get_ball) * right_normal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Super Cancel
	#if controller().isSuperCancelPressed():
		#ball.prepareToShoot = false
		#ball.shooting = false
		#ball.shootPowerFactor = 0.0
		#$"./ShootPowerBar".value = 0.0
	
	var screen_pos = cameras.currentCamera().unproject_position( position )
	
	$"./PowerBar/ShootPowerBar".position = Vector2( screen_pos.x -25, screen_pos.y + 15 )
	
	#var _animationTree = $"./Animations/AnimationTree"
	#var stateMachine = animationTree.get("parameters/playback")
	
	#if stateMachine.get_current_node() == "Jog_02":
	##if stateMachine.get_current_node() == "FastRun-loop":		
		#var tf = get_global_transform()
		#var right_normal = tf.basis.z
		#animationTree.advance( 1.0 * jogAnimationSpeed * linear_velocity.dot(right_normal) * delta )
	#elif stateMachine.get_current_node() == "Kick_05":
		#animationTree.advance( 1.8 * delta )
	#else:
		#animationTree.advance(delta)
	
	if Input.is_action_just_pressed( controller().getAction("Shoot") ):
		currentState = State.STATE_PREPARE_TO_KICK
		shootDirection = Vector3( -direction.y, 0.0, -direction.x )
		ball.prepareToShoot = true
		ball.shootHeightFactor = getShootHeightBarValue()
		ball.shootCurveFactor = getShootCurveFactor()
		ball.shootSpinFactor = getShootSpinFactor()
		
	if linear_velocity.length() == 0.0:
		currentState = State.STATE_IDLE
		#stateMachine.travel("Idle_01")
	#else:
		#stateMachine.travel("Jog_02")
		#stateMachine.travel("FastRun-loop")
		
	if Input.is_action_just_released( controller().getAction("Shoot") ):
		ball.shooting = true
		ball.shootPowerFactor = getShootPowerBarValue()
		
	if ball.prepareToShoot and delta_position.length() < 0.8:
		currentState = State.STATE_KICK
		#stateMachine.travel("Kick_05")
		
	if Input.is_action_pressed( controller().getActionShoot() ):
		currentState = State.STATE_PREPARE_TO_KICK
		$"./PowerBar/ShootPowerBar".value += shootPowerRiseSpeed
	else:
		$"./PowerBar/ShootPowerBar".value -= 0.1 * shootPowerRiseSpeed
	
	$"./PowerBar/ShootHeightBar".value = 0.5 - 0.5 * Input.get_joy_axis(playerID, JOY_AXIS_RIGHT_Y)
	
	#var speed = 0.2
