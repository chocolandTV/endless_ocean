extends Sprite2D
class_name Seagull_Anim

@export_range(0.1, 2.0, 0.1) var flap_speed: float = 0.7
@export_range(0.0, 0.2, 0.005) var scale_x_amount: float = 0.08
@export_range(0.0, 0.12, 0.005) var skew_amount: float = 0.04

@export_range(5.0, 12.0, 1.0) var animation_time : float = 5.0
@export_range(80.0, 300.0, 10.0) var orbit_radius_min: float = 120.0
@export_range(80.0, 300.0, 10.0) var orbit_radius_max: float = 220.0
## base positions
var _flap_time: float = 0.0
var _resting_scale: Vector2
var _resting_skew: float

## Orbit state
var _is_flying: bool = false
var _elapsed_time: float = 0.0
var _flight_scale: float = 1.0
var _orbit_angle: float = 0.0
var _orbit_radius: float = 0.0
var _orbit_speed: float = 0.0
var _orbit_direction: float = 1.0
###
func _ready() -> void:
	_resting_scale = scale
	_resting_skew = skew

func _process(delta: float) -> void:
	if !multiplayer.is_server():
		return
	if _is_flying:
		_elapsed_time = minf(_elapsed_time + delta, animation_time)
		var progress: float = _elapsed_time / animation_time
		_flight_scale = 1.0 - progress
		_fly_around_parent(delta)
		if progress >= 1.0:
			_is_flying = false
			var seagull_entity := get_parent() as Seagull_Entity
			if seagull_entity == null:
				push_error("Seagull_Anim must be a child of Seagull_Entity.")
				return
			seagull_entity.seagull_despawned.emit(seagull_entity.name)
	_flap_time += delta * TAU * flap_speed
	scale.x = _resting_scale.x * _flight_scale * (1.0 + sin(_flap_time) * scale_x_amount)
	scale.y = _resting_scale.y * _flight_scale
	skew = _resting_skew + sin(_flap_time + PI * 0.5) * skew_amount

func start_seagull()->void:
	_elapsed_time = 0.0
	_flight_scale = 1.0
	_orbit_angle = randf_range(0.0, TAU)
	_orbit_radius = randf_range(orbit_radius_min, orbit_radius_max)
	_orbit_speed = randf_range(0.6, 1.2)
	_orbit_direction = -1.0 if randi_range(0, 1) == 0 else 1.0
	_is_flying = true
	_fly_around_parent(0.0)

func _fly_around_parent(delta: float) -> void:
	var seagull_entity := get_parent() as Node2D
	if seagull_entity == null:
		push_error("Seagull_Anim must be a child of a Node2D.")
		_is_flying = false
		return

	_orbit_angle = fposmod(_orbit_angle + _orbit_direction * _orbit_speed * delta, TAU)
	global_position = seagull_entity.global_position + Vector2.from_angle(_orbit_angle) * _orbit_radius
	rotation = _orbit_angle + _orbit_direction * PI / 2.0