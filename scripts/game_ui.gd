extends CanvasLayer
class_name Game_UI

#global class
static var instance : Game_UI =null

## minigame variables
var minigame_ui : Control  =null
var is_minigame_running : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance  = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_minigame_ui_instance(_control : Control) ->void:
	minigame_ui =  _control
	print("GAME_UI: Minigame_ui setted")

func set_minigame_enabled(_bool : bool = true) ->void:
	print("Game_UI: is active: ",_bool)
	is_minigame_running = _bool
	minigame_ui.visible = _bool
