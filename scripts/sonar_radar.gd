extends Control
class_name Sonar_Radar
@export var radar_radius :float = 100.0
@export var detection_radius : float = 1000.0
@export var signal_noise : float = 12.0
@export_range(0.0, 10.0, 0.1) var fish_density: float = 0.8
@export_range(50.0, 2000.0, 50.0) var field_cell_size: float = 250.0
@export var field_seed: int = 13891

const FISHING_DISTANCE : float = 40.0

var player_node : CharacterBody2D

var local_fish : Array[Dictionary]  =[]
# Keep removed IDs across field rebuilds so procedural fish do not respawn.
var _removed_fish : Dictionary = {}
var pulse_time: float = 0.0
var last_cell_bounds: Vector4i = Vector4i.ZERO
var has_generated_field: bool = false

func _enter_tree() -> void:
	add_to_group("sonar_radar")

func _ready() -> void:
	if multiplayer.is_server():
		return
	if player_node != null:
		_generate_fish_field()

func remove_fish(_position : Vector2) -> void:
	_generate_fish_field()
	var fish_index : int = _find_nearby_fish_index(_position)
	if fish_index == -1:
		return

	# Remove the nearest fish at the fishing spot and remember it for later rebuilds.
	var fish_id : Vector3i = local_fish[fish_index]["id"]
	_removed_fish[fish_id] = true
	local_fish.remove_at(fish_index)
	queue_redraw()

# Returns true when the fishing position is within FISHING_DISTANCE of a sonar fish.
func check_fish_is_nearby(_position : Vector2) -> bool:
	_generate_fish_field()
	return _find_nearby_fish_index(_position) != -1

# Returns the nearest fish index inside the fishing range, or -1 when none is close.
func _find_nearby_fish_index(_position : Vector2) -> int:
	var nearest_index : int = -1
	var nearest_distance_squared : float = FISHING_DISTANCE * FISHING_DISTANCE

	for fish_index in range(local_fish.size()):
		var fish_position : Vector2 = local_fish[fish_index]["position"]
		var distance_squared : float = _position.distance_squared_to(fish_position)
		if distance_squared <= nearest_distance_squared:
			nearest_index = fish_index
			nearest_distance_squared = distance_squared

	return nearest_index

func set_player_node(player: CharacterBody2D) -> void:
	player_node = player
	if is_node_ready():
		_generate_fish_field()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if multiplayer.is_server():
		return
	pulse_time += delta

	if player_node == null:
		return

	_generate_fish_field()

	queue_redraw()

func _generate_fish_field() -> void:
	if player_node == null:
		return

	var player_position: Vector2 = player_node.global_position
	var min_cell_x: int = floori((player_position.x - detection_radius) / field_cell_size)
	var min_cell_y: int = floori((player_position.y - detection_radius) / field_cell_size)
	var max_cell_x: int = floori((player_position.x + detection_radius) / field_cell_size)
	var max_cell_y: int = floori((player_position.y + detection_radius) / field_cell_size)
	var cell_bounds := Vector4i(min_cell_x, min_cell_y, max_cell_x, max_cell_y)
	if has_generated_field and cell_bounds == last_cell_bounds:
		return

	has_generated_field = true
	last_cell_bounds = cell_bounds
	local_fish.clear()

	for cell_y in range(min_cell_y, max_cell_y + 1):
		for cell_x in range(min_cell_x, max_cell_x + 1):
			var rng := RandomNumberGenerator.new()
			rng.seed = hash(Vector3i(field_seed, cell_x, cell_y))

			var count: int = floori(fish_density)
			if rng.randf() < fish_density - count:
				count += 1

			for fish_index in range(count):
				var fish_position := Vector2(
					(cell_x + rng.randf()) * field_cell_size,
					(cell_y + rng.randf()) * field_cell_size
				)
				var fish_strength : float = rng.randf_range(0.65, 1.0)
				# This cell-and-index key stays stable because each cell uses a seeded RNG.
				var fish_id := Vector3i(cell_x, cell_y, fish_index)
				if _removed_fish.has(fish_id):
					continue

				local_fish.append({
					"id": fish_id,
					"position": fish_position,
					"strength": fish_strength
				})
####################################### DRAWING MINIMAP
func _draw() -> void:
	var center :Vector2 = size / 2.0
	var scale_factor : float = radar_radius / detection_radius

	# radar ring
	draw_arc(
		center,
		radar_radius,
		0.0,
		TAU,
		64,
		Color(0.133,0.041,0.031,0.8),#main color
		2.0
	)
	draw_arc(
		center,
		radar_radius * 0.33,
		0.0,
		TAU,
		64,
		Color(0.2,0.9,0.7,0.35),#border color
		1.0
	)
	# draw boat
	draw_circle(center,4.0, Color.WHITE)

	if player_node == null:
		return

	# local fish signals
	for fish in local_fish:
		var _pos: Vector2 = fish["position"] - player_node.global_position
		if _pos.length() > detection_radius:
			continue
		var _strength : float = fish["strength"]

		var radar_pos: Vector2 = center + _pos * scale_factor
		var _pulse : float = 1.0 + 0.25 * sin(pulse_time * 5.0)
		var _radius : float  = 3.0 + _strength * _pulse * 3.0

		#signal power
		var alpha : float  = clampf(
			1.0 - _pos.length() / detection_radius,
			0.1,
			1.0
		)

		draw_circle(
			radar_pos,
			_radius,
			Color(0.3,1.0,0.5, alpha)
		)
		#signal border
		draw_arc(
			radar_pos,
			_radius* 2.0,
			0.0,
			TAU,
			24,
			Color(0.3,1.0,0.5, alpha * 0.5),
			1.0
		)