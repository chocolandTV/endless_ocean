extends AudioStreamPlayer2D

@onready var timer :Timer =$Timer
var is_cooldown: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return
	if Input.is_action_just_pressed("horn"):
		_try_to_horn()

func _try_to_horn() ->void:
	if !is_cooldown:
		var _pitch_scale : float = randf_range(0.85, 1.15)
		pitch_scale = _pitch_scale
		play()
		is_cooldown = true
		timer.start()

func _on_timer_timeout() ->void:
	is_cooldown = false
