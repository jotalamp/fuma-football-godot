extends CharacterBody3D

@export_range(0.0, 1.0) var sensitivity = 0.25
@export var anim_tree: AnimationTree

@export var playerID = 0
@export var controllerIDNumber = 0
@export var maxSpeed = 0.6 * 10.0 # m/s
@export var jogAnimationSpeed = 0.6
@export var maxTurningTorque = 11000.0
@export var shootPowerRiseSpeed : float = 3.0
@export var ballLockRange = 3.0 # meters
@export var skeleton : Skeleton3D
@export var physicalBoneSimulator : PhysicalBoneSimulator3D
@export var rightFoot : PhysicalBone3D
@export var leftFoot : PhysicalBone3D
@export var IK : SkeletonIK3D
@export var IK2 : SkeletonIK3D
@export var Hips : PhysicalBone3D

const SPEED = 5.0
const JUMP_VELOCITY = 5

enum State { STATE_IDLE, STATE_DRIBBLE, STATE_PREPARE_TO_KICK, STATE_KICK }

var currentCamera : Camera3D
var currentState = State.STATE_IDLE
var shootDirection = Vector3()
var direction = Vector2()
var inputDirection2D = Vector2()
var inputDirection3D = Vector3()
@onready var shootHeightBar = %ShootHeightBar
@onready var shootPowerBar = %ShootPowerBar

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_position = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.relative
		
func controller():
	return %Controllers.controllers[controllerIDNumber-1]
	
func getControllerIDString():
	return "C" + str(controllerIDNumber) + "_"

func getAxis(name1: String):
	var fullName = getControllerIDString() + name1
	return Input.get_axis( fullName + "-", fullName + "+")
	
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
		
func _process(delta: float) -> void:
	#mouse_position *= sensitivity
	#var yaw = mouse_position.x
	#rotate_y(deg_to_rad(-yaw))
	
	direction = -get_global_transform().basis.x
	
	var animationTree = %AnimationTree
	var stateMachine = animationTree.get("parameters/playback")
	
	var tf = get_global_transform()
	var right_normal = tf.basis.x
	#animationTree.root_motion_track = ""
	
	var speed := Vector2(velocity.x, velocity.z).length()
		
	if Input.is_action_just_pressed( controller().getAction("Shoot") ):
		stateMachine.travel("Gk_catch")
	elif speed < 0.2:
		currentState = State.STATE_IDLE
		stateMachine.travel("Idle_12")
	elif speed < 5.0:
		stateMachine.travel("Jog_02")
	#else:
		#stateMachine.travel("FastRun")
	
	if stateMachine.get_current_node() == "Jog_02":
		animationTree.advance( speed * delta )
	elif stateMachine.get_current_node() == "FastRun":
		animationTree.advance( speed * delta )
	elif stateMachine.get_current_node() == "Gk_catch":
		animationTree.advance( 2.0 * delta )
	elif stateMachine.get_current_node() == "Kick_05":
		animationTree.root_motion_track = "Armature/Skeleton3D:mixamorig5_Hips"
		animationTree.advance( delta )
	else:
		animationTree.advance(speed * delta)
	#animationTree.advance(delta)
	
	if Input.is_action_just_pressed( controller().getAction("Shoot") ):
		currentState = State.STATE_PREPARE_TO_KICK
		shootDirection = Vector3( -direction.y, 0.0, -direction.x )
		%Ball.prepareToShoot = true
		%Ball.shootHeightFactor = getShootHeightBarValue()
		%Ball.shootCurveFactor = getShootCurveFactor()
		%Ball.shootSpinFactor = getShootSpinFactor()
		

		
	if Input.is_action_just_released( controller().getAction("Shoot") ):
		#stateMachine.travel("Kick_05")
		%Ball.shooting = true
		%Ball.shootPowerFactor = getShootPowerBarValue()
		currentState = State.STATE_KICK
		
	var delta_position = %Ball.position - (position - 1.0 * Vector3(direction.normalized().y,0.0,direction.normalized().x))
		
	if %Ball.prepareToShoot and delta_position.length() < 0.8:
		#pass
		currentState = State.STATE_KICK
		#stateMachine.travel("Kick_05")
		
	if Input.is_action_pressed( controller().getActionShoot() ):
		currentState = State.STATE_PREPARE_TO_KICK
		#stateMachine.travel("Kick_05")
		%ShootPowerBar.value += delta * shootPowerRiseSpeed
	else:
		%ShootPowerBar.value -= 0.1 * delta * shootPowerRiseSpeed
	
	%ShootHeightBar.value = 0.7 + 0.7*Input.get_action_strength("C1_ShootHeight+") - 0.3*Input.get_action_strength("C1_ShootHeight-")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
		return

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (transform.basis * Vector3(input_dir.y, 0, -input_dir.x)).normalized()
	
	var ball_pos = %Ball.global_position
	var ball_future_pos = ball_pos + %Ball.linear_velocity
	
	var gk_pos = global_position
	var goal_pos = Vector3(-54,0,0)
	var ball_gk_dist = (ball_pos - gk_pos).length()
	var ball_distance_from_goal = (goal_pos-ball_pos).length()/55.0
	var target_pos = (0.2*ball_future_pos+0.8*goal_pos)
	if target_pos.x < -54.0:
		target_pos.x = -54
	target_pos.z = (1.0-0.7*ball_distance_from_goal)*ball_pos.z
	var pos_delta = target_pos - gk_pos
	pos_delta.y = 0
	#if pos_delta.length() > 2.0:
	#direction = pos_delta
		
	# Handle Jump.
	if is_on_floor() and Input.is_action_just_pressed("C1_Shoot"):
			velocity.y = JUMP_VELOCITY

	var dir2 = %Ball.global_position - global_position
	direction.y = 0
	
	if dir2.length() > 0.1:
		dir2 = dir2.normalized()
		#rotate_y(atan2(direction.z,direction.x))
		#rotation.y = atan2(dir2.z,-dir2.x)
		
	#rotate_y(mouse_position.x)
	
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
		
	#var local_vel = transform.basis.inverse() * velocity
	#anim_tree.set("parameters/blend_position", Vector2(local_vel.z, -local_vel.x))
	maxSpeed = 4.5 + 4.5 * Input.get_action_strength("C1_Run")
	
	#superCancelValue = Input.get_action_strength("SuperCancelValue")
	
	currentCamera = %Cameras.currentCamera()
	
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
	
	input = inputDirection2D
	
	var inputAngle = atan2( input.y, input.x )
	%Arrow.rotation = Vector3( %Arrow.rotation.x, inputAngle - rotation.y, %Arrow.rotation.z )
		
	# AI
	var deltaPosition3D = position - ( %Ball.position + %Ball.linear_velocity * delta  )
	var deltaPosition2D = Vector2(deltaPosition3D.z,deltaPosition3D.x)
	
	if (
			#isNearestPlayerToBall() 
			#and 
			abs( %Ball.position.z ) < 50.0
			and not controller().isSuperCancelPressed()
			and deltaPosition2D.length() < ballLockRange
			and deltaPosition2D.length() > 0.7
	):
		if ( ( currentState == State.STATE_PREPARE_TO_KICK ) or ( currentState == State.STATE_KICK ) ):
			input = 3.0 * deltaPosition2D
		else:
			currentState = State.STATE_DRIBBLE

			var r = deltaPosition2D.normalized().dot(inputDirection2D.normalized())
			
			if ( deltaPosition2D.length() < 0.6 ) and ( inputDirection2D.length() < 0.3 ):
				#input = Vector2.ZERO
				pass
			elif r > 0.0: # input direction similar to direction to ball
				input = lerp( deltaPosition2D, inputDirection2D, 0.1 )
			else: # input direction opposite to direction to ball
				input = lerp( deltaPosition2D, -0.1*inputDirection2D.normalized(), 0.2 )
	else:
		input = inputDirection2D
		
	direction = -get_global_transform().basis.x
	
	var targetAngle = atan2( -input.x, input.y )
	
	if( targetAngle < 0.0 ):
		targetAngle += 2.0 * PI
	
	var currentAngle = rotation.y + PI
	var deltaAngle = targetAngle - currentAngle
	
	if deltaAngle > PI:
		deltaAngle -= 2.0 * PI
	elif deltaAngle < -PI:
		deltaAngle += 2.0 * PI
	
	#if deltaPosition2D.length() > 0.1:
		#rotate_y( 0.0005 * input.length() * deltaPosition2D.length() * deltaPosition2D.length() * (deltaAngle*abs(deltaAngle)));
	
	if input.length() > 0.2:
		rotation.y = targetAngle
	
	if input.length() > 0.2:
		velocity.x = -input.y * SPEED
		velocity.z = -input.x * SPEED
	else:
		velocity.x = 0#move_toward(velocity.x, 0, SPEED)
		velocity.z = 0#move_toward(velocity.z, 0, SPEED)
	
	var tf = get_global_transform()
	var vel = self.get_platform_velocity()
	var right_normal = tf.basis.x
	#get the orthogonal velocity vector
	#var right_vel = right_normal.dot(vel) * right_normal
	#apply_central_impulse( - mass * right_vel );
	
	#delta_position = $"/root/Root/Ball".position - (position - 1.0 * Vector3(direction.normalized().y,0.0,direction.normalized().x))
	
	move_and_slide()
