extends Node
class_name Game_Connection
@export var is_Server : bool =  true
### This script handles server side calculation like new highscores, peer connection and disconnections

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_Server:
		HighLevelNetworkHandler.start_server()
	else:
		HighLevelNetworkHandler.start_client()