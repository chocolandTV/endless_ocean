extends Control
@onready var player_name_label : Label  =$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot/HBoxContainer/Value
@onready var player_id_label : Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot2/HBoxContainer/Value
@onready var game_version_label  : Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot3/HBoxContainer/Value
@onready var total_food_label : Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot4/HBoxContainer/Value
@onready var horn_used_label : Label =$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot5/HBoxContainer/Value
@onready var max_player_label : Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot6/HBoxContainer/Value
@onready var server_disconnects_label : Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot7/HBoxContainer/Value
@onready var failed_disconnects_label : Label =$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot8/HBoxContainer/Value
@onready var speedrun_time_label : Label =$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot9/HBoxContainer/Value
@onready var total_traveled_label : Label =$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot10/HBoxContainer/Value
@onready var total_games_done_label : Label =$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot11/HBoxContainer/Value
@onready var total_time_label : Label =$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot12/HBoxContainer/Value
@onready var total_session_label : Label =$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot13/HBoxContainer/Value
@onready var total_fish_catched_label : Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Boat_Stats_Container/MarginContainer/VBoxContainer/Stat_Slot14/HBoxContainer/Value

@onready var fish_slot_01 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot
@onready var fish_slot_02 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot2
@onready var fish_slot_03 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot3
@onready var fish_slot_04 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot4
@onready var fish_slot_05 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot5
@onready var fish_slot_06 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot6
@onready var fish_slot_07 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot7
@onready var fish_slot_08 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot8
@onready var fish_slot_09 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot9
@onready var fish_slot_10 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot10
@onready var fish_slot_11 : PanelContainer = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Fish_Dex_Container/GridContainer/Fish_Slot11




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#after stats control signal cast, if enabled
	Game_State_Manager.instance.stats_enabled.connect(_on_stats_enabled)
	# when persistent data is loaded load fish dex
	PersistentData.persistent_data_loaded.connect(_load_fish_dex)

	_load_fish_dex()
func _on_stats_enabled(_bool : bool) ->void:
	if _bool:
		_reload_fish_dex()
func _reload_fish_dex() ->void:
	_load_fish_dex()

func get_time_formated(_current_playtime : float) -> String:
    # format current playtime in hh:mm:ss
	var total_seconds : int = floori(_current_playtime / 1000.0)
	var hours : int = floori(total_seconds / 3600.0)
	var minutes : int = floori((total_seconds % 3600) / 60.0)
	var seconds : int = total_seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, seconds]

func _load_fish_dex() ->void:
	player_name_label.text = GameData.get_game_data_string("player_id")
	game_version_label.text = GameData.get_game_data_string("version")
	total_food_label.text = GameData.get_game_data_string("food")
	horn_used_label.text = GameData.get_game_data_string("horn_used")
	max_player_label.text = GameData.get_game_data_string("max_player_in_session")
	server_disconnects_label.text= GameData.get_game_data_string("server_disconnects")
	failed_disconnects_label.text = GameData.get_game_data_string("failed_disconnects")

	speedrun_time_label.text = get_time_formated(GameData.get_game_data_float("GDQ"))
	total_traveled_label.text = GameData.get_game_data_string("total_travel")
	total_time_label.text = get_time_formated(GameData.get_game_data_float("total_time"))
	total_session_label.text = GameData.get_game_data_string("total_server_sessions")

	total_fish_catched_label.text = GameData.get_game_data_string("total_fish")

	# fish data slots
	#fish_slot_01.set_slot(_name, _texture, _fish_catched, _fish_chance, _fish_score)
	if GameData.get_game_data_int("total_bausa") > 0.0:
		fish_slot_01.visible =true
		fish_slot_01.set_slot("BAUSA",
		 GameData.FISH_TEXTURE_PATHS[0],
		 GameData.get_game_data_string("total_bausa"),
		 str(GameData.FISH_TYPE_WEIGHT[0]),
		 GameData.get_game_data_string("biggest_bausa"))
	else:
		fish_slot_01.visible  = false
	##################################################################################
	if GameData.get_game_data_int("total_oremo") > 0.0:
		fish_slot_02.visible =true
		fish_slot_02.set_slot("OREMO",
		 GameData.FISH_TEXTURE_PATHS[1],
		 GameData.get_game_data_string("total_oremo"),
		 str(GameData.FISH_TYPE_WEIGHT[1]),
		 GameData.get_game_data_string("biggest_oremo"))
	else:
		fish_slot_02.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_dorrie") > 0.0:
		fish_slot_03.visible =true
		fish_slot_03.set_slot("DORRIE",
		 GameData.FISH_TEXTURE_PATHS[2],
		 GameData.get_game_data_string("total_dorrie"),
		 str(GameData.FISH_TYPE_WEIGHT[2]),
		 GameData.get_game_data_string("biggest_dorrie"))
	else:
		fish_slot_03.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_radioactive") > 0.0:
		fish_slot_04.visible =true
		fish_slot_04.set_slot("RADIOACTIVE",
		 GameData.FISH_TEXTURE_PATHS[3],
		 GameData.get_game_data_string("total_radioactive"),
		 str(GameData.FISH_TYPE_WEIGHT[3]),
		 GameData.get_game_data_string("biggest_radioactive"))
	else:
		fish_slot_04.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_scarla") > 0.0:
		fish_slot_05.visible =true
		fish_slot_05.set_slot("SCARLA",
		 GameData.FISH_TEXTURE_PATHS[4],
		 GameData.get_game_data_string("total_scarla"),
		 str(GameData.FISH_TYPE_WEIGHT[4]),
		 GameData.get_game_data_string("biggest_scarla"))
	else:
		fish_slot_05.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_red_lobfish") > 0.0:
		fish_slot_06.visible =true
		fish_slot_06.set_slot("RED LOBFISH",
		 GameData.FISH_TEXTURE_PATHS[5],
		 GameData.get_game_data_string("total_red_lobfish"),
		 str(GameData.FISH_TYPE_WEIGHT[5]),
		 GameData.get_game_data_string("biggest_red_lobfish"))
	else:
		fish_slot_06.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_scarfase") > 0.0:
		fish_slot_07.visible =true
		fish_slot_07.set_slot("SCARFASE",
		 GameData.FISH_TEXTURE_PATHS[6],
		 GameData.get_game_data_string("total_scarfase"),
		 str(GameData.FISH_TYPE_WEIGHT[6]),
		 GameData.get_game_data_string("biggest_scarfase"))
	else:
		fish_slot_07.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_deadhearth") > 0.0:
		fish_slot_08.visible =true
		fish_slot_08.set_slot("DEADHEARTH",
		 GameData.FISH_TEXTURE_PATHS[7],
		 GameData.get_game_data_string("total_deadhearth"),
		 str(GameData.FISH_TYPE_WEIGHT[7]),
		 GameData.get_game_data_string("biggest_deadhearth"))
	else:
		fish_slot_08.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_tangle") > 0.0:
		fish_slot_09.visible =true
		fish_slot_09.set_slot("TANGLE",
		 GameData.FISH_TEXTURE_PATHS[8],
		 GameData.get_game_data_string("total_tangle"),
		 str(GameData.FISH_TYPE_WEIGHT[8]),
		 GameData.get_game_data_string("biggest_tangle"))
	else:
		fish_slot_09.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_elvfish") > 0.0:
		fish_slot_10.visible =true
		fish_slot_10.set_slot("ELVFISH",
		 GameData.FISH_TEXTURE_PATHS[9],
		 GameData.get_game_data_string("total_elvfish"),
		 str(GameData.FISH_TYPE_WEIGHT[9]),
		 GameData.get_game_data_string("biggest_elvfish"))
	else:
		fish_slot_10.visible  = false
	##################################################################################

	if GameData.get_game_data_int("total_amenii") > 0.0:
		fish_slot_11.visible =true
		fish_slot_11.set_slot("AMENII",
		 GameData.FISH_TEXTURE_PATHS[10],
		 GameData.get_game_data_string("total_amenii"),
		 "0,0001",
		 GameData.get_game_data_string("biggest_amenii"))
	else:
		fish_slot_11.visible  = false