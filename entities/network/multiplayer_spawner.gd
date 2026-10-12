extends MultiplayerSpawner

@export var network_player_scene : PackedScene

func _ready() -> void:
	multiplayer.peer_connected.connect(_spawn_player)
	multiplayer.peer_disconnected.connect(_despawn_player)

func _spawn_player(_id: int) ->void:
	

	if !multiplayer.is_server():
		return
	
	var _player_node : Node2D = network_player_scene.instantiate()

	_player_node.name  = str(_id)

	get_node(spawn_path).call_deferred("add_child", _player_node)
	
	print("Player Spawned wiht id : ", str(_id))

	_player_node.global_position = Vector2.ZERO
	
func _despawn_player(_id : int) ->void:
	if !multiplayer.is_server():
		return

	get_node(spawn_path).get_node(str(_id)).queue_free()
	
