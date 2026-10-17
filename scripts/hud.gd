extends Control

@onready var food_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_01/Food_Label
@onready var progress_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_02/Progress_Label
@onready var event_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_03/Event_Label
@onready var active_fisher_label : Label =$PanelContainer/MarginContainer/HBoxContainer/Player_Info_04/Active_Fisher_Label
@onready var last_catch_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_05/Last_Catch_Label
@onready var time_played_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_06/Time_Played_Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Network.game_state_updated.connect(_on_game_state_updated)

func _on_game_state_updated(_state:  Dictionary)->void:
	food_label.text = "Food: %s" %[_state["food"][Game_State_Manager.instance.player_node.name]]
	var _percent : float  = _state["progess"] / Network.DEFAULT_BOSS_FOOD_CONDITION * 100
	progress_label.text = "Progress: %" %[str( _percent)]
	var _text_is_spawned :String = "No Event"
	if _state["boss_spawned"]:
		_text_is_spawned = "Big fish event"
	event_label.text  =    _text_is_spawned
	active_fisher_label.text  = str(_state["active_fishers"].size())
	last_catch_label.text = "Last Catch: %s Fishes" %[_state["last_fisher"]]
	time_played_label.text = Game_State_Manager.instance.get_current_playtime()
