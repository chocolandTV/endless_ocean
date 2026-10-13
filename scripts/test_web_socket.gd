extends Node2D
@export var is_server : bool = true
const SERVER_IP : String = "wss://endlessocean.mineralz2135.de:9080"
const SERVER_LOCALHOST : String = "ws://127.0.0.1:9080"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_server:
		_on_server_button_pressed()
	else: 
		_on_button_pressed()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass



func _on_server_button_pressed() -> void:
	var result:= Network.start_server()
	if result == OK:
		print("Server started")


func _on_button_pressed() -> void:
	var result:= Network.connect_to_server(SERVER_LOCALHOST)
	if result == OK:
		print("connection successed")


func _on_angel_button_pressed() -> void:
	Network.set_fishing.rpc_id(1,true)
	Network.request_fish.rpc_id(1)
