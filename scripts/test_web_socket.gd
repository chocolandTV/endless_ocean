extends Node2D
### THIS SCRIPT HANDLES SERVER OR CLIENT CONNECTION TO LOCAL OR EXTERNAL SERVER
@export var is_server : bool = true

@export var testing_local : bool = true

const SERVER_IP : String = "wss://endlessocean.mineralz2135.de/ws"
const SERVER_LOCALHOST : String = "ws://127.0.0.1:9080"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _server_ip : String = SERVER_IP
	if testing_local:
		_server_ip = SERVER_LOCALHOST

	if is_server:
		#if is server start server
		var result:= Network.start_server()
		if result == OK:
			print("Server started")
	else:
		# client connected
		var result:= Network.connect_to_server(_server_ip)
		if result == OK:
			print("connection successed")
			