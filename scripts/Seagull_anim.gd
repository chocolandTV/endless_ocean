extends Sprite2D
class_name Seagull_Anim

@export_range(0.1, 2.0, 0.1) var flap_speed: float = 0.7
@export_range(0.0, 0.2, 0.005) var scale_x_amount: float = 0.08
@export_range(0.0, 0.12, 0.005) var skew_amount: float = 0.04

@export_range(5.0, 12.0, 1.0) var animation_time : float = 5.0
## base positions
var _flap_time: float = 0.0
var _resting_scale: Vector2
var _resting_skew: float

##  start and target position and time
var _start_position : Vector2 = Vector2.ZERO
var _target_position:  Vector2 = Vector2.ZERO
var _start_seagul : bool =  false
###
func _ready() -> void:
	_resting_scale = scale
	_resting_skew = skew

func _process(delta: float) -> void:
	if _start_seagul:
		global_position = global_position.lerp(_target_position, delta * animation_time)
	_flap_time += delta * TAU * flap_speed
	scale.x = _resting_scale.x * (1.0 + sin(_flap_time) * scale_x_amount)
	skew = _resting_skew + sin(_flap_time + PI * 0.5) * skew_amount

func start_seagull(_start_pos : Vector2, _target_pos: Vector2)->void:

	_start_seagul = true

	_start_position =  _start_pos
	_target_position =  _target_pos

