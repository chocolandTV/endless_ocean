extends Label

#@export var button : Button
var _name : String = "Betty"
var _is_enabled : bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#if button:
	#	button.pressed.connect(_on_button_pressed)
	_name = GameSettings.ship_names.pick_random()
	_update_name_visibility()
func _on_button_pressed() ->void:
	_is_enabled = !_is_enabled
	_update_name_visibility()

func _update_name_visibility() -> void:
	text = _name if _is_enabled and GameSettings.show_name_tags else ""