extends Node2D
@export var _is_seagull_flying : bool = true

@onready var _timer  :Timer = $Timer

const MIN_MAX_EVENT_COOLDOWN : Vector2 = Vector2(1,2)#Vector2(10, 360)

var is_endemic_life_event_running : bool = false
var _endemic_life_spawner : MultiplayerSpawner
var current_event_scene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_timer.timeout.connect(_on_timer_timeout)


func _on_timer_timeout() ->void:
	if !_is_seagull_flying:
		return
	if GameSettings.is_game_server:
		if is_endemic_life_event_running:
			# stop event # queue free event x
			is_endemic_life_event_running = false
		if _check_player_count():
			_spawn_seagul_entity()


func _check_player_count() ->bool:
	return Network.get_player_count()

func _spawn_seagul_entity() ->void:
	is_endemic_life_event_running = true
	#get player position
	var _players : Array[Node] = get_tree().get_nodes_in_group("players")
	if _players:
		var _selected_player : Node =  _players.pick_random()
		if _selected_player:
			var _player_pos : Vector2 = _selected_player.global_position
			# get random point near player and calculate target position that cross the player

			$Endemic_Spawner.spawn_seagull(_player_pos)


func set_spawner(_endemic : MultiplayerSpawner)->void:
	if !_is_seagull_flying:
		return
	#set endemic spawner
	if _endemic:
		_endemic_life_spawner = _endemic
		print("Server: Endemic Life Spawner setted start timer")

	var _time : float =  randf_range(MIN_MAX_EVENT_COOLDOWN.x, MIN_MAX_EVENT_COOLDOWN.y)
	if _timer:
		_timer.wait_time = _time
		print("Server: Event Timer waittime : %s " %[_time])
		_timer.start()