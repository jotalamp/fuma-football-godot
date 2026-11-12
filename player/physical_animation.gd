extends Skeleton3D

@export var target_skeleton: Skeleton3D

@export var linear_spring_stiffness: float = 1200.0
@export var linear_spring_damping: float = 40.0
@export var max_linear_force: float = 9999.0

@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0

var physics_bones

# Called when the node enters the scene tree for the first time.
func _ready():
	#physical_bones_start_simulation()
	$PhysicalBoneSimulator3D.physical_bones_start_simulation()
	physics_bones = $PhysicalBoneSimulator3D.get_children().filter(func(x): return x is PhysicalBone3D)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
# spring related function
func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)

func _physics_process(delta):
	#return
	for b in physics_bones:
		var target_transform: Transform3D = target_skeleton.global_transform * target_skeleton.get_bone_global_pose(b.get_bone_id())
		var current_transform: Transform3D = global_transform * get_bone_global_pose(b.get_bone_id())
		
		var current_q: Quaternion = current_transform.basis.get_rotation_quaternion()
		var target_q: Quaternion = target_transform.basis.get_rotation_quaternion()
		var error_q: Quaternion = target_q * current_q.inverse()

		# Varmista lyhin reitti kvaternionille
		if error_q.w < 0:
			error_q = -error_q

		var axis = error_q.get_axis()
		var angle = error_q.get_angle()
		var torque = axis * angle * angular_spring_stiffness - b.angular_velocity * angular_spring_damping
