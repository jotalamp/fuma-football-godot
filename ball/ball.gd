extends RigidBody3D

var _initial_transform
@export var maxShootPower : float
var shooting = false
var prepareToShoot = false
var reset

@onready var players = $"/root/Root/TeamHome"
@export var nearestPlayer : Player

@export var magnusForceFactor = 0.3
@export var shootHeightFactor = 2.0
@export var shootPowerFactor = 1.0
@export var shootCurveFactor = 2.0
@export var shootSpinFactor = 2.0

var collision_force : Vector3 = Vector3.ZERO

func _ready():
	reset = false
	#shootPowerBar.value = 0.0
	_initial_transform = self.global_transform

func _process(_delta):
	
	#nearestPlayer = players.nearestPlayerToBall()
	
	var delta_position = nearestPlayer.position - position
	
	#var playerShootPowerBarValue = nearestPlayer.shootPowerBarValue()

	#var player_direction = Vector2()
	#player_direction = nearestPlayer.direction.normalized
	
	#if ( shooting or prepareToShoot ) and delta_position.length() < 0.5:
	
	# cancel shoot if ball is lost
	if shooting and delta_position.length() > 4.0:
		shooting = false
		nearestPlayer.resetPowerBar()
		
	
	if shooting and delta_position.length() < 0.6:
		
		#var player_direction_3d = Vector3( -player_direction.y, 0.0, -player_direction.x )
		var player_direction_3d = Vector3.ZERO
		player_direction_3d += 2.5 * nearestPlayer.inputDirection3D
		player_direction_3d = player_direction_3d.normalized()
		
		apply_central_impulse( 
				( 0.1 + 1.3 * shootPowerFactor * maxShootPower ) * 
				Vector3( 
					player_direction_3d.x, 
					( 0.2 + nearestPlayer.controller().getShootHeight() ) * 0.6 * shootPowerFactor, 
					player_direction_3d.z 
				).normalized() );
		
		#var top_spin = ( 0.7 - Input.get_joy_axis(0, 6) ) * player_direction_3d.cross(Vector3(0.0, 1.0, 0.0)).normalized()
		shootSpinFactor = nearestPlayer.getShootSpinFactor()
		var top_spin = 0.1 * ( 0.1 - 1.1 * shootSpinFactor ) * player_direction_3d.cross(Vector3(0.0, 1.0, 0.0)).normalized()
		top_spin *= -1.0
		#var top_spin = shootSpinFactor * player_direction_3d.cross(Vector3(0.0, 1.0, 0.0))
		apply_torque_impulse( 0.7 * Vector3( top_spin.x, -5.0 * nearestPlayer.controller().getAxis("Curve"), top_spin.z ) )
		shooting = false
		nearestPlayer.shooted()
		prepareToShoot = false
		
		$KickAndBounceSound.volume_db = 40.0 * shootPowerFactor
		$KickAndBounceSound.play()
	
	# Dribble
	if delta_position.length() < 0.4 and nearestPlayer.inputDirection2D.length() > 0.1:
		var positionAtFrontOfPlayer = nearestPlayer.position + 30.0 * nearestPlayer.inputDirection3D
		var impulseDirection = positionAtFrontOfPlayer - position
		impulseDirection.y = 0.25 * impulseDirection.length()
		apply_central_impulse( 0.2 * impulseDirection.normalized() * nearestPlayer.inputDirection2D.length() );

func _physics_process(delta):
	if position.y < 0.23:
		linear_damp = 0.32
		#angular_damp = 0.32
	else:
		linear_damp = 0.12
		angular_damp = 0.09
	# magnus force
	apply_central_force( 10.0 * magnusForceFactor * delta * angular_velocity.cross(linear_velocity) )

func _integrate_forces(state):
	if Input.is_action_just_pressed("reset"):
		reset = true
		
	if reset:
		#state.set_transform(_initial_transform)
		transform = nearestPlayer.global_transform
		transform.origin += 2.0 * transform.basis.z + Vector3.UP
		if Input.is_action_pressed("CursorChange"):
			state.set_transform(_initial_transform)
		else:
			state.set_transform(transform)
		linear_velocity = Vector3()
		reset = false
		
	collision_force = Vector3.ZERO
	
	for i in range(state.get_contact_count()):
		collision_force += state.get_contact_impulse(i) * state.get_contact_local_normal(i)

func _on_ResetTimer_timeout():
	reset = true
	$"/root/Root/Referee/WhistleSound".play()

func _on_body_shape_entered(_body_rid: RID, body: Node, _body_shape_index: int, _local_shape_index: int) -> void:
	if collision_force.length() > 0.5:
		
		if body.is_in_group("posts"):
			$HitPostSound.volume_db = 1.8 * collision_force.length()
			$HitPostSound.play()
			
		elif collision_force.length() > 0.5:
			$KickAndBounceSound.volume_db = 1.9 * collision_force.length()
			$KickAndBounceSound.play()
		pass
