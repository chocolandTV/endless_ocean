extends MultiplayerSpawner

@export var player_network_scene : PackedScene
@export var boss_fish_scene : PackedScene

@export var camera : Camera2D
func _ready() -> void:
	# connect to the multiplayer peer connect signal, every time some join the websocket server
	multiplayer.peer_connected.connect(_spawn_player)
	multiplayer.peer_disconnected.connect(_despawn_player)
	# adding camera after player node instantiate
	spawned.connect(_on_player_spawned)
	Network.boss_spawned.connect(_spawn_boss)

func _spawn_player(_id : int) ->void:
	
	# only server can spawn players
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
	#add child to spawner 
	spawn_parent.add_child(_player_node)
	#add network player array
	Network.players.append(_player_node)

func _spawn_boss() -> void:
	if !multiplayer.is_server():
		return
	if boss_fish_scene == null:
		SoundManager.play_sfx("Error_Sound")
		push_error("MultiplayerSpawner requires a boss fish scene.")
		return
	var spawn_parent: Node = get_node(spawn_path)
	if spawn_parent.get_node_or_null("GiantFish") != null:
		return

	var boss_node: Node = boss_fish_scene.instantiate()
	boss_node.name = "GiantFish"
	spawn_parent.add_child(boss_node)

func _despawn_player(peer_id: int) -> void:
	if !multiplayer.is_server():
		return

	var spawn_parent: Node = get_node(spawn_path)
	var player_node: Node = spawn_parent.get_node_or_null(str(peer_id))
	if player_node != null:
		player_node.queue_free()
		Network.players.erase(player_node)

func _on_player_spawned(player: Node) -> void:
	if !player.is_multiplayer_authority():
		return
	if camera == null:
		SoundManager.play_sfx("Error_Sound")
		push_error("MultiplayerSpawner requires a camera for the local player.")
	elif !camera.has_method("follow_player"):
		SoundManager.play_sfx("Error_Sound")
		push_error("MultiplayerSpawner camera must implement follow_player().")
	else:
		camera.call("follow_player", player)
