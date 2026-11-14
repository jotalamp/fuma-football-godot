extends RigidBody3D

"""
	Active Ragdolls - Ragdoll Bone
		by Nemo Czanderlitch/Nino Čandrlić
			@R3X-G1L       (godot assets store)
			R3X-G1L6AME5H  (github)

	This is the script which transfers the rotation from the RigidBody3D
	to the skeleton.
"""

@export var bone_name: String
var BONE_INDEX : int = -1

"""
	INIT
"""
func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
	else:
		assert(get_parent() is Skeleton3D, "The Ragdoll Bone[%s] is supposed to be a child of a Skeleton3D" % [self.name])
		assert(bone_name != "", "The Ragdoll Bone[%s] needs to have its bone name defined" % [self.name])
		BONE_INDEX = get_parent().find_bone(bone_name)
		assert(BONE_INDEX >= 0, "The Ragdoll Bone's[%s] bone name[%s] does not match any bone in the skeleton" % [self.name, bone_name])

@onready var skeleton: Skeleton3D = $Skeleton3D

"""
	APPLY OWN ROTATION TO THE RESPECTIVE BONE IN PARENT SKELETON
"""
func _physics_process(_delta: float) -> void:
	
	if bone_name.ends_with("Head"):
		apply_central_force(Vector3(0,200,0))
		
	if bone_name.ends_with("Hips"):
		var ball_pos = %Ball.global_position
		
		if ball_pos.x < 0:
			var gk_pos = %AAA.global_position
			var goal_pos = Vector3(-53,0,0)
			var ball_distance_from_goal = (goal_pos-ball_pos).length()/55.0
			var target_pos = (0.2*ball_pos+0.8*goal_pos)
			target_pos.z = (1.1-0.9*ball_distance_from_goal)*ball_pos.z
			var pos_delta = target_pos - gk_pos
			pos_delta.y = pos_delta.y
			apply_central_force(2000*pos_delta.normalized()-90*linear_velocity)
		
	var bone_global_rotation : Basis = get_parent().get_bone_global_pose(BONE_INDEX).basis
	var b2t_rotation : Basis = bone_global_rotation.inverse() * self.transform.basis
	
	var transform2 = Transform3D(get_parent().get_bone_pose(BONE_INDEX).basis * b2t_rotation)
	
	transform2.origin = get_parent().get_bone_pose(BONE_INDEX).origin
	
	get_parent().set_bone_pose(BONE_INDEX, transform2)
