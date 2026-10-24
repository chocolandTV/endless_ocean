extends MultiplayerSpawner

const BASE_DISTANCE : float  = 1000
@onready var seagull_scene : PackedScene = load("res://scenes/seagull_01.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_seagull(_player_pos : Vector2) ->void:
	
	# only server can spawn players
	if !multiplayer.is_server():
		return

	var spawn_parent: Node = get_node(spawn_path)

	var _seagull_node : Node2D = seagull_scene.instantiate()
	# add child to spawner
	spawn_parent.add_child(_seagull_node)
	# get direction and perfect positions equals the playerpos
	var _random_direction : Vector2 = Vector2(randf_range(-1,1),randf_range(-1,1))

	var _start_pos : Vector2 = (_random_direction * BASE_DISTANCE) + _player_pos

	var _target_pos : Vector2 = (_random_direction * -BASE_DISTANCE) + _player_pos

	_seagull_node.global_position = _start_pos

	_seagull_node.start_seagull(_start_pos, _target_pos)