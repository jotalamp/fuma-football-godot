extends Node

@onready var players = get_tree().get_nodes_in_group("players")
var selectedPlayerNumber = 0

var colors = [
	Color( 1.0, 0.0, 0.0 ),
	Color( 0.0, 0.0, 1.0 ),
	Color( 0.0, 1.0, 0.0 ),
	Color( 1.0, 1.0, 0.0 ),
	Color( 1.0, 0.0, 1.0 ),
	Color( 0.0, 1.0, 1.0 ),
	Color( 1.0, 1.0, 1.0 ),
	Color( 0.0, 0.0, 0.0 )
	]

func selectedPlayer():
	return players[selectedPlayerNumber]
	
func idOfNearestPlayerToBall():
	var IdOfNearestPlayer = 0
	
	for i in range( 0, players.size() ):
		if players[i].distanceToBall() < players[IdOfNearestPlayer].distanceToBall():
			IdOfNearestPlayer = i
	
	return IdOfNearestPlayer
	
func nearestPlayerToBall():
	return players[idOfNearestPlayerToBall()]

func _process(_delta):
	if Input.is_action_just_pressed("CursorChange"):
		selectedPlayerNumber = (selectedPlayerNumber+1)%players.size()
