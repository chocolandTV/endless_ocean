extends Node
@onready var _timer : Timer = $Timer

const FISH_TEXTURE_PATHS : Array[String] = [
	
	"res://assets/textures/fish_types/fish_00.png",## Bausa
	"res://assets/textures/fish_types/fish_01.png",## Oremo
	"res://assets/textures/fish_types/fish_02.png",## Dorrie
	"res://assets/textures/fish_types/fish_03.png",## Radioactive
	"res://assets/textures/fish_types/fish_04.png",## Scarla
	"res://assets/textures/fish_types/fish_05.png",## Red Lobfish
	"res://assets/textures/fish_types/fish_06.png",## Scarfase
	"res://assets/textures/fish_types/fish_07.png",## Deadhearth
	"res://assets/textures/fish_types/fish_09.png",## Tangle
	"res://assets/textures/fish_types/fish_08.png",## Elvfish
	"res://assets/textures/fish_types/fish_10.png" ## Amenii

	
]
const FISH_TYPE_WEIGHT : Array[int] = [
	75,#75%,#"res://assets/textures/fish_types/fish_00.png", Bausa
	10,#10%,#"res://assets/textures/fish_types/fish_01.png", Oremo
	3,#3%,#"res://assets/textures/fish_types/fish_02.png", Dorrie
	3,#3%,#"res://assets/textures/fish_types/fish_03.png", Radioactive Fish
	2,#2%,#"res://assets/textures/fish_types/fish_04.png", Scarla
	2,#2%,#"res://assets/textures/fish_types/fish_05.png", Red Lobfish
	2,#2%,#"res://assets/textures/fish_types/fish_06.png", Scarfase
	1,#1%,#"res://assets/textures/fish_types/fish_07.png", Deadhearth
	1,#1%#"res://assets/textures/fish_types/fish_09.png", Tangle
	1#1%,#"res://assets/textures/fish_types/fish_08.png", Elvfish
]
var default_game_data : Dictionary = {
    "player_id" : 0,# store player id
    "version" : 0, # store current version
    "food" : 0, # current food
    "horn_used" : 0, #how many horn was used
    "max_player_in_session" : 0, # total player count in a server session
    "server_disconnects"  : 0, # when server kills the process or restart
    "failed_disconnects" : 0, # when cant join to server
    #settings
    "master_volume" : 0,
    "music_volume" : 0,
    "sound_volume" : 0,
    "show_name_tags" : 0,
    ### total stats
    "GDQ" : 0, # time for game done
    "total_travel"  : 0, # total movement in miles
    "total_games_done" : 0, # total game done played
    "total_time" : 0, # total time on server
    "total_server_sessions" : 0, # total server connects
    ############# 
    # fish data
    "total_fish" :  0, # total catched fish
    "total_bausa" : 0,
	"total_oremo" : 0,
	"total_dorrie" : 0,
	"total_radioactive" : 0,
	"total_scarla" : 0,
	"total_red_lobfish" : 0,
	"total_scarfase" : 0,
	"total_deadhearth" : 0,
	"total_tangle" : 0,
	"total_elvfish" : 0,
    "total_amenii" : 0,
    "biggest_bausa" : 0,
	"biggest_oremo" : 0,
	"biggest_dorrie" : 0,
	"biggest_radioactive" : 0,
	"biggest_scarla" : 0,
	"biggest_red_lobfish" : 0,
	"biggest_scarfase" : 0,
	"biggest_deadhearth" : 0,
	"biggest_tangle" : 0,
	"biggest_elvfish" : 0,
    "biggest_amenii" : 0
}
var _game_data : Dictionary = {
    "player_id" : 0,# store player id
    "version" : 0, # store current version
    "food" : 0, # current food
    "horn_used" : 0, #how many horn was used
    "max_player_in_session" : 0, # total player count in a server session
    "server_disconnects"  : 0, # when server kills the process or restart
    "failed_disconnects" : 0, # when cant join to server
    #settings
    "master_volume" : 0,
    "music_volume" : 0,
    "sound_volume" : 0,
    "show_name_tags" : 0,
    ### total stats
    "GDQ" : 0, # time for game done
    "total_travel"  : 0, # total movement in miles
    "total_games_done" : 0, # total game done played
    "total_time" : 0, # total time on server
    "total_server_sessions" : 0, # total server connects
    ############# 
    # fish data
    "total_fish" :  0, # total catched fish
    "total_bausa" : 0,
	"total_oremo" : 0,
	"total_dorrie" : 0,
	"total_radioactive" : 0,
	"total_scarla" : 0,
	"total_red_lobfish" : 0,
	"total_scarfase" : 0,
	"total_deadhearth" : 0,
	"total_tangle" : 0,
	"total_elvfish" : 0,
    "total_amenii" : 0,
    "biggest_bausa" : 0,
	"biggest_oremo" : 0,
	"biggest_dorrie" : 0,
	"biggest_radioactive" : 0,
	"biggest_scarla" : 0,
	"biggest_red_lobfish" : 0,
	"biggest_scarfase" : 0,
	"biggest_deadhearth" : 0,
	"biggest_tangle" : 0,
	"biggest_elvfish" : 0,
    "biggest_amenii" : 0
}
################### BASE FUNCTIONS ##############
func _ready() -> void:
    _timer.timeout.connect(_on_timer_timeout)
    PersistentData.load_game()

func _process(delta: float) -> void:
    _game_data["total_time"] += delta

#################### END BASE FUNCTIONS ###########
func _on_timer_timeout() ->void:
    save_game_data()

func get_game_data_int(_key: String) -> int:
    if _game_data.has(_key):
        return _game_data[_key]
    else:
        return 0

func get_game_data_float(_key: String) -> float:
    if _game_data.has(_key):
        return _game_data[_key]
    else:
        return 0.0

func get_game_data_string(_key: String) ->String:
    if _game_data.has(_key):
        return str(_game_data[_key])
    else:
        return "0"
func add_game_data(_key : String, _value : float) -> void:
    if _game_data.has(_key):
        _game_data[_key] += _value

func set_game_data(_key : String, _value : Variant) ->void:
    if _game_data.has(_key):
        _game_data[_key]  = _value

### PERSISTENT APPLY NEW GAME DATA
func apply_game_data_from_persistent(_loaded_game_data: Dictionary) ->void:
    _game_data =  _loaded_game_data

func save_game_data() ->void:
    PersistentData.save_game(_game_data)

