extends CanvasLayer
class_name Game_UI
@export var statistic_menu : Control
@export var hud_menu : Control
@export var sonar_menu : Control
#global class
static var instance : Game_UI =null

## minigame variables
var minigame_ui : Control  =null
var is_minigame_running : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance  = self
	Game_State_Manager.instance.stats_enabled.connect(_on_stats_enabled)
#signal cast on
func _on_stats_enabled(_bool : bool) ->void:
	set_statistic_menu(_bool)

### right now without transition
func set_statistic_menu(_bool : bool) ->void:
	hud_menu.visible = !_bool
	sonar_menu.visible  =!_bool
	statistic_menu.visible = _bool

func set_minigame_ui_instance(_control : Control) ->void:
	minigame_ui =  _control
	print("GAME_UI: Minigame_ui setted")

func set_minigame_enabled(_bool : bool = true) ->void:
	print("Game_UI: is active: %s" % _bool)
	is_minigame_running = _bool
	minigame_ui.visible = _bool
