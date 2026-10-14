extends Control

@export var radar_radius :float = 100.0
@export var detection_radius : float = 500.0
@export var signal_noise : float = 12.0
@export var fish_count : int  = 5
@export var fish_drift_speed : float = 12.0

# privates clientside
var local_fish : Array[Dictionary]  =[]
var pulse_time: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_generate_test_fish()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pulse_time += delta

	for fish in local_fish:
		var drift : Vector2 = fish["drift"]
		var pos: Vector2 = fish["position"]

		pos += drift * fish_drift_speed * delta
		#signal drift
		if randf() < delta * 0.5:
			drift = drift.rotated(randf_range(-0.8,0.8))

		if pos.length() > detection_radius * 0.85:
			drift  = -pos.normalized()
		

		fish["position"]  = pos
		fish["drift"]  = drift

	# draw fish positions only once per frame	
	queue_redraw()
		

func _generate_test_fish() ->void:
	local_fish.clear()

	for i in range(fish_count):
		var angle: float = randf_range(0.0,TAU)
		var distance :float =(randf_range(
			detection_radius * 0.15,
			detection_radius * 0.9
		))
		local_fish.append({
			"position" : Vector2.from_angle(angle) * distance,
			"drift" : Vector2.from_angle(randf_range(0.0, TAU)),
			"strength" : randf_range(0.65, 1.0)
		})

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

	# local fish signals
	for fish in local_fish:
		var _pos: Vector2 = fish["position"]
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