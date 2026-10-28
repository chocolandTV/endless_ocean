extends Node2D

var _endemic_life_spawner : MultiplayerSpawner
var current_event_scene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.fishing_seagull_started.connect(_on_fishing_seagull_started)


func _on_fishing_seagull_started(_pos:  Vector2) ->void:

	if multiplayer.is_server():
		if _check_player_count():
			_spawn_seagul_entity(_pos)
	#	else:
	#		print("no players online")


func _check_player_count() ->bool:
	return Network.get_player_count() >0

func _spawn_seagul_entity(_pos : Vector2) ->void:
	if _endemic_life_spawner:
		_endemic_life_spawner.spawn_seagull(_pos)
	

func set_spawner(_endemic : MultiplayerSpawner)->void:

	#set endemic spawner
	if _endemic:
		_endemic_life_spawner = _endemic
		#print("Server: Endemic Life Spawner setted start timer")
