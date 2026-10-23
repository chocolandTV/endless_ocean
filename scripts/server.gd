extends Node2D

@onready var _timer  :Timer = $Timer

const MIN_MAX_EVENT_COOLDOWN : Vector2 = Vector2(10, 360)

var is_endemic_life_event_running : bool = false
var _endemic_life_spawner : MultiplayerSpawner
var current_event_scene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_timer.timeout.connect(_on_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
func _on_timer_timeout() ->void:
	if is_endemic_life_event_running:
		# stop event # queue free event x
		is_endemic_life_event_running = false
func _check_player_count() ->bool:
	return false

func _spawn_seagul_entity() ->void:
	pass

func set_spawner(_endemic : MultiplayerSpawner)->void:
	_endemic_life_spawner = _endemic
	print("Server: Endemic Life Spawner setted start timer")
	_timer.start()