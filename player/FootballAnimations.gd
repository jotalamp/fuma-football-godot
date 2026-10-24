extends Node3D

#@export var ap : AnimationPlayer
@export var currentCamera : Camera3D
@export var ball : RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	var ap = $"./AnimationPlayer"
	var animations = ['Chip','Idle_01','Idle_03','Idle_04','Kick_02','Kick_03']
	#var animations = ['Idle_02']
	ap.speed_scale = 2.0
	#ap.autoplay = true
	#ap.set_autoplay(ap.get_current_animation())
	
	for animation in animations:
		animation = ap.get_animation(animation)	
		animation.loop = true
		animation.loop_mode = Animation.LOOP_LINEAR
		#animation.speed_scale = 0.1
		#ap.loop = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var ap = $"./AnimationPlayer"
	var player = $"../"
	ap.speed_scale = 0.8 * player.linear_velocity.length()
