extends Panel
@export var _fish_scene : PackedScene

const OFFSET_DISTANCE : float  = 15.0
const GRID_SIZE : int =  5

var current_grid : float=  0.0
var current_index : float  = 0.0

func _ready() ->void:
	pass

func spawn_fishcrowd(_count : int) ->void:
	#clear childs
	for x in get_children():
		x.queue_free()
	
	# reset parameter
	current_grid = 0.0

	current_index = 1.0

	############## start instantiate
	for x in _count:
		var _instance : TextureRect = _fish_scene.instantiate() as TextureRect
		add_child(_instance)
		_instance.position = Vector2(current_index * OFFSET_DISTANCE, current_grid * OFFSET_DISTANCE)
		current_index += 1
		
		if current_index > 5.0:
			# next row
			current_index = 0.0
			current_grid += 1.0
		
		if current_grid > 5.0:
			current_grid = 0.5

