extends Node

@onready var cameras = get_tree().get_nodes_in_group("cameras")
#@onready var player = get_tree().get_nodes_in_group("Player")[0]
@export var player : Node3D
var cameraNumber = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func currentCamera():
	return get_viewport().get_camera_3d()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("selectCameraTV"):
		cameras[0].make_current()
	if Input.is_action_just_pressed("selectCameraHorizontal"):
		cameras[1].make_current()
	if Input.is_action_just_pressed("selectCameraVertical"):
		cameras[2].make_current()
		
	if Input.is_action_just_pressed("selectNextCamera"):
		cameraNumber = (cameraNumber+1)%3
		cameras[cameraNumber].make_current()
