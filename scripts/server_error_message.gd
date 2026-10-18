extends PanelContainer

@onready var _animation_player : AnimationPlayer =$MarginContainer/HBoxContainer/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(_on_visible_changed)

func _on_visible_changed()->void:
	if visible:
		_animation_player.play("try_to_connect_anim")
	else:
		_animation_player.stop()