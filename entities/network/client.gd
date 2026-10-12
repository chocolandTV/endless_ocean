extends Node
class_name Game_Client

@export var is_Client : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_Client:
		HighLevelNetworkHandler.start_client()
