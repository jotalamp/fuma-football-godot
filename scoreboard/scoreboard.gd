extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@onready var time = $"./Background/Time"
@onready var score = $"./Background/Score"
@onready var timer = $"./Timer"
@onready var scoreHome = $"/root/Root/Goals/GoalA"
@onready var scoreAway = $"/root/Root/Goals/GoalB"
@onready var teamNameLabelHome = $Background/TeamNameLabelHome
@onready var teamNameLabelAway = $Background/TeamNameLabelAway
@onready var teamHome = $"/root/Root/TeamHome"
@onready var teamAway = $"/root/Root/TeamAway"

var timeStart = 0
var timeNow = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	teamNameLabelHome.set_text(teamHome.getTeamData().shortName)
	teamNameLabelAway.set_text(teamAway.getTeamData().shortName)
	timeStart = int(Time.get_unix_time_from_system()*1000)
	pass # Replace with function body.

func updateScore():
	score.set_text( String(scoreHome.goals) + " - " + String(scoreAway.goals))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#timeNow = OS.get_unix_time()
	timeNow = int(Time.get_unix_time_from_system()*1000)
	var timeElapsed = timeNow - timeStart
	timeElapsed /= 1000 # milliseconds to seconds
	var minutes = timeElapsed / 60
	var seconds = timeElapsed % 60
	
	var secondsString
	
	if seconds < 10:
		secondsString = "0" + String( "%1.0f" % seconds )
	else:
		secondsString = String( "%2.0f" % seconds )
		
	time.set_text( String( "%3.0f" % minutes ) + ":" + secondsString )
	
#	pass
