extends Node2D
### THIS SCRIPT HANDLES SERVER OR CLIENT CONNECTION TO LOCAL OR EXTERNAL SERVER
@export var is_server : bool = true

const SERVER_IP : String = "wss://endlessocean.mineralz2135.de/ws"
const SERVER_LOCALHOST : String = "ws://127.0.0.1:9080"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_server:
		#if is server start server
		var result:= Network.start_server()
		if result == OK:
			print("Server started")
	else:
		# client connected
		var result:= Network.connect_to_server(SERVER_IP)
		if result == OK:
			print("connection successed")
			