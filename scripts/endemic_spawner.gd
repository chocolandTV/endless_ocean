extends MultiplayerSpawner

const BASE_DISTANCE : float  = 1000
@onready var seagull_scene : PackedScene = load("res://scenes/seagull_01.tscn")
var _id_endemic_life: int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_seagull(_pos : Vector2) ->void:
	
	# only server can spawn players
	if !multiplayer.is_server():
		return

	var spawn_parent: Node = get_node(spawn_path)

	var _name : String = str("Seagull_" + str(_id_endemic_life))
	if spawn_parent.has_node(_name):
		return
	
	var _seagull_node : Node2D = seagull_scene.instantiate()
	# add child to spawner
	#count up
	_id_endemic_life += 1
	_seagull_node.name = _name

	spawn_parent.add_child(_seagull_node)
	
	#print("Spawn Seagull at position: %s" % _pos)
	_seagull_node.global_position = _pos
	#add signal
	_seagull_node.seagull_despawned.connect(_on_seagull_despawn)

	_seagull_node.start_seagull()

func _on_seagull_despawn(_seagull_id : String) ->void:
	if !multiplayer.is_server():
		return

	var spawn_parent: Node = get_node(spawn_path)
	var _seagull_node: Node = spawn_parent.get_node_or_null(str(_seagull_id))
	if _seagull_node != null:
		_seagull_node.queue_free()
