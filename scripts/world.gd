extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		return
	SoundManager.start_overworld_music()

