extends RigidBody3D

func _physics_process(delta: float) -> void:
	var ball_pos = %Ball.global_position
	
	if ball_pos.x < 0:
		var gk_pos = %AAA.global_position
		var goal_pos = Vector3(-53,0,0)
		var ball_distance_from_goal = (goal_pos-ball_pos).length()/55.0
		var target_pos = (0.2*ball_pos+0.8*goal_pos)
		target_pos.z = (1.1-0.9*ball_distance_from_goal)*ball_pos.z
		var pos_delta = target_pos - gk_pos
		pos_delta.y = 0*pos_delta.y
		if pos_delta.length() > 2.0:
			apply_central_force(800*pos_delta.normalized()-90*linear_velocity)
		else:
			apply_central_force(600*pos_delta-90*linear_velocity)

	#apply_torque(Vector3(0,10,0))
