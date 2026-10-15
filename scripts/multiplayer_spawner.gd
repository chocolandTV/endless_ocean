extends MultiplayerSpawner

@export var player_network_scene : PackedScene

@export var vbox : VBoxContainer
func _ready() -> void:
	multiplayer.peer_connected.connect(_spawn_player)

func _spawn_player(_id : int) ->void:
	if _id == 0 or _id == 1:
		print("Multiplayer Spawner: Is Server, return")
		return
	
	var _player_node : Node2D = player_network_scene.instantiate()

	_player_node.name  = str(_id)

	get_node(spawn_path).call_deferred("add_child", _player_node)

	# delete canvas shit
	vbox.hide()
