extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var goals = 0
onready var scoreboard = $"/root/Root/Scoreboard"
onready var resetTimer = $"/root/Root/ResetTimer"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass


func _on_Goal_body_entered(body):
	if body.is_in_group("ball") and resetTimer.time_left == 0.0:
		resetTimer.start()
		goals += 1
		scoreboard.updateScore()
		$"/root/Root/Stadium/CrowdSound".unit_db = 11.0
	
