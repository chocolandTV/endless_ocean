extends Control

@export var camera : Camera2D

@onready var food_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_01/Food_Label
@onready var progress_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_02/Progress_Label
@onready var event_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_03/Event_Label
@onready var active_fisher_label : Label =$PanelContainer/MarginContainer/HBoxContainer/Player_Info_04/Active_Fisher_Label
@onready var last_catch_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_05/Last_Catch_Label
@onready var time_played_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_06/Time_Played_Label
@onready var position_grid_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_07/Position_Grid_Label
@onready var _server_error_panel : PanelContainer = $Server_Error_Message
@onready var _minigame_transition : PanelContainer = $Minigame_Transition

##game done
@onready var _game_done_panel : HBoxContainer =$PanelContainer/MarginContainer/HBoxContainer/Player_Info_08
@onready var _game_done_label : Label = $PanelContainer/MarginContainer/HBoxContainer/Player_Info_08/game_done
var _current_games_done : int  = 0

var _current_catched_fish : int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.is_server():
		return
	Network.game_state_updated.connect(_on_game_state_updated)
	Network.connection_changed.connect(_on_connection_changed)
	Network.boss_finished.connect(_on_boss_finished)
	Game_State_Manager.instance.minigame_finished.connect(_on_minigame_finished)


func _on_boss_finished() ->void:
	_game_done_panel.visible = true
	_current_games_done +=1
	_game_done_label.text ="GameDone x %s" %[str(_current_games_done)]

func _physics_process(_delta: float) -> void:
	if multiplayer.is_server():
		return
	time_played_label.text = Game_State_Manager.instance.get_current_playtime()
	if camera:
		position_grid_label.text = _format_position_to_sea_coordiates(camera.global_position)
func _on_connection_changed(_connected :bool)->void:
	print("connection changed")
	if _connected:
		print("Client Connected - HUD Signal abort")
		return 
	else: 
		show_server_offline_panel()

func show_server_offline_panel() ->void:
	SoundManager.play_sfx("Error_Sound")
	_server_error_panel.visible = true
func _on_game_state_updated(_state: Dictionary)->void:
	var food_by_player : Dictionary = _state.get("food", {})
	var player_id : int = Game_State_Manager.instance.player_id
	if food_by_player.has(player_id):
		food_label.text = "Food: %s" % str(food_by_player[player_id])

	if _state.has("progress"):
		var percent : float = float(_state["progress"]) / Network.DEFAULT_BOSS_FOOD_CONDITION * 100.0
		progress_label.text = "Progress: %s%%" % str(percent)

	var _text_is_spawned :String = "No Event"
	if _state.get("boss_spawned", false):
		_text_is_spawned = "Anema Koi"
	event_label.text  =    _text_is_spawned
	var active_fishers : int = _state.get("active_fishers",1)
	
	active_fisher_label.text = str(active_fishers)

	var last_fisher : Dictionary = _state.get("last_fisher", {})
	if last_fisher.has("name") and last_fisher.has("fish_count"):
		last_catch_label.text = "%s catch %s Fish" % [last_fisher["name"], last_fisher["fish_count"]]

func _on_minigame_finished(_success :bool , _new_fish : int,_time : float)->void:
	if _success:
		var _text : String = "%s Fish caught! Yeah" % _new_fish

		_minigame_transition.visible = true
		_minigame_transition.on_minigame_transition_win(_text, 1)

		last_catch_label.text = "x %s + %s" %[_current_catched_fish, _new_fish]
		_current_catched_fish += _new_fish
		# create timer 0.5s await timer finished
		await get_tree().create_timer(1).timeout
		last_catch_label.text = "x %s" %[_current_catched_fish]
	else:
		_minigame_transition.visible = true
		_minigame_transition.on_minigame_transition_win("Fish escaped!", 1)

func _format_position_to_sea_coordiates(_position: Vector2) -> String:
	var column : int = maxi(1, ceili(absf(_position.x) / 1000.0))
	var column_name : String = ""
	while column > 0:
		var letter_index : int = (column - 1) % 26
		column_name = char(65 + letter_index) + column_name
		column = floori((column - 1) / 26.0)

	if _position.x < 0:
		column_name = "-" + column_name

	var row : int = floori(_position.y / 1000.0)
	return "%s-%d" % [column_name, row]