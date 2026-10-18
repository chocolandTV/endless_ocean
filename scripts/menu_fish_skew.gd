extends Sprite2D

@export_range(0.1, 5.0, 0.1) var swim_speed: float = 1.4
@export_range(0.0, 0.2, 0.005) var skew_amount: float = 0.055
@export_range(0.0, 12.0, 0.5) var bob_amount: float = 3.0
@export_range(0.0, 0.1, 0.005) var pitch_amount: float = 0.025

var _swim_time: float = 0.0
var _resting_skew: float
var _resting_position: Vector2
var _resting_rotation: float

func _ready() -> void:
	_resting_skew = skew
	_resting_position = position
	_resting_rotation = rotation

func _process(delta: float) -> void:
	_swim_time += delta * TAU * swim_speed

	# Layer a softer secondary beat over the main bend for a more natural swim cycle.
	var body_sway: float = sin(_swim_time) + sin(_swim_time * 2.0 - 0.8) * 0.18
	skew = _resting_skew + body_sway * skew_amount
	position.y = _resting_position.y + sin(_swim_time - 0.5) * bob_amount
	rotation = _resting_rotation + sin(_swim_time - 1.0) * pitch_amount
