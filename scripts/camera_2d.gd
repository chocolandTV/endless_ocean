extends Camera2D

@export var smoothing_speed: float = 8.0
var target: Node2D

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = smoothing_speed
	make_current()

func follow_player(player: Node2D) -> void:
	target = player

func _process(_delta: float) -> void:
	if is_instance_valid(target):
		global_position = target.global_position
