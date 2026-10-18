extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.game_state_updated.connect(_on_game_state_updated)

func _on_game_state_updated(_state : Dictionary)->void:
	if _state.has("boss_health"):
		set_value_no_signal(float(_state["boss_health"]))

