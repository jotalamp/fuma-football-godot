extends Control

@export var dot_01 : TextureRect 
@export var dot_02 : TextureRect 

@onready var player = $"/root/Root/TeamHome/Player"
@onready var player2 = $"/root/Root/TeamHome/Player"
@onready var ball = $"/root/Root/Ball"
@onready var dot_ball = $"./Dot_Ball"
@onready var dots = []
@onready var teamHomePlayers = [] 
@onready var teamAwayPlayers = [] 

const PLAYER_DOT = preload("res://radar/radar_player_dot.tscn")

func addPlayerDot():
	var dotInstance = PLAYER_DOT.instantiate()
	add_child(dotInstance, true)
	print(dotInstance.get_path())
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	dot_01.position = Vector2( -2.45 * player.position.x, -60.0-2.45 * player.position.z )
	dot_02.position = Vector2( -2.45 * player2.position.x, -60.0-2.45 * player2.position.z )
	dot_ball.position = Vector2( -2.45 * ball.position.x, -60-2.45 * ball.position.z)
	dot_01.modulate = player.getTeamColor()
	dot_02.modulate = player2.getTeamColor()
