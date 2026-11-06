extends Node

@onready var cameras = get_tree().get_nodes_in_group("cameras")
#@onready var player = get_tree().get_nodes_in_group("Player")[0]
@export var player : Node3D
var cameraNumber = 0
const defaultCameraNumber = 2
const CAMERA_NAMES := ["TV Camera", "Horizontal Camera", "Vertical Camera"]

func _ready():
	cameraNumber = defaultCameraNumber
	cameras[cameraNumber].make_current()

func currentCamera():
	return get_viewport().get_camera_3d()
	
func getCurrentCameraName():
	return CAMERA_NAMES[cameraNumber]

func _process(_delta):
	if Input.is_action_just_pressed("selectCameraTV"):
		cameraNumber = 0
	if Input.is_action_just_pressed("selectCameraHorizontal"):
		cameraNumber = 1
	if Input.is_action_just_pressed("selectCameraVertical"):
		cameraNumber = 2
	if Input.is_action_just_pressed("selectNextCamera"):
		cameraNumber = (cameraNumber+1)%3
		
	cameras[cameraNumber].make_current()
