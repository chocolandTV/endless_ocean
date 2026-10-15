extends MultiplayerSpawner

@export var player_network_scene : PackedScene

@export var vbox : VBoxContainer
@export var camera : Camera2D
func _ready() -> void:
	multiplayer.peer_connected.connect(_spawn_player)
	spawned.connect(_on_player_spawned)

func _spawn_player(_id : int) ->void:
	if vbox != null:
		vbox.hide()

	if !multiplayer.is_server():
		return

	if _id == 0 or _id == 1:
		print("Multiplayer Spawner: Is Server, return")
		return

	var spawn_parent: Node = get_node(spawn_path)
	var player_name: String = str(_id)
	if spawn_parent.has_node(player_name):
		return

	var _player_node : Node2D = player_network_scene.instantiate()

	_player_node.name = player_name

	spawn_parent.add_child(_player_node)

func _on_player_spawned(player: Node) -> void:
	if !player.is_multiplayer_authority():
		return
	if camera == null:
		push_error("MultiplayerSpawner requires a camera for the local player.")
	elif !camera.has_method("follow_player"):
		push_error("MultiplayerSpawner camera must implement follow_player().")
	else:
		camera.call("follow_player", player)
