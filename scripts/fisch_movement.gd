extends TextureRect

const fish_texture_paths : Array[String] = [
	
	"res://assets/textures/fish_types/fish_00.png",
	"res://assets/textures/fish_types/fish_01.png",
	"res://assets/textures/fish_types/fish_02.png",
	"res://assets/textures/fish_types/fish_03.png",
	"res://assets/textures/fish_types/fish_04.png",
	"res://assets/textures/fish_types/fish_05.png",
	"res://assets/textures/fish_types/fish_06.png",
	"res://assets/textures/fish_types/fish_07.png",
	"res://assets/textures/fish_types/fish_08.png",
	"res://assets/textures/fish_types/fish_09.png",
	"res://assets/textures/fish_types/fish_10.png"

	
]
const SWIM_ROTATION : float = 0.08
const SWIM_SCALE : float = 0.025

var swim_origin : Vector2 = Vector2.ZERO
var swim_radius : float = 0.0
var swim_phase : float = 0.0
var swim_speed : float = 1.0
var swim_time : float = 0.0
var base_scale : Vector2 = Vector2.ONE

func start_swimming(origin: Vector2, radius: float, phase: float, speed: float, _type : int) -> void:
	#secure type case
	if _type == null:
		push_error("_fish_type has error set to default")
		_type = 0
	if _type < 0 or _type > fish_texture_paths.size():
		push_error("_fish_type ")
	#load texture
	var _new_texture : Texture2D = load(fish_texture_paths[_type])
	#print(_new_texture)
	#assign
	texture = _new_texture
	swim_origin = origin
	swim_radius = maxf(radius, 0.0)
	swim_phase = phase
	swim_speed = speed
	swim_time = 0.0
	base_scale = scale
	pivot_offset = size / 2.0
	set_process(true)

func stop_swimming() -> void:
	set_process(false)

func _process(delta: float) -> void:
	swim_time += delta * swim_speed
	var angle := swim_time + swim_phase
	var drift := Vector2(
		sin(angle),
		sin(angle * 2.0 + swim_phase) * 0.35
	) * swim_radius

	position = swim_origin + drift
	rotation = sin(angle * 2.0) * SWIM_ROTATION
	var squash := sin(angle * 2.0) * SWIM_SCALE
	scale = base_scale * Vector2(1.0 + squash, 1.0 - squash)
