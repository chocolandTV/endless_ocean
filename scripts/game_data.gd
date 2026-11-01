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
    "server_disconnects" : 0, # when server kills the process or restart
    "failed_disconnects" : 0, # when cant join to server
    #settings
    "master_volume" : 0.4,
    "music_volume" : 0.4,
    "sound_volume" : 0.4,
    "show_name_tags" : 1,
    ### total stats
    "GDQ" : 0.0, # time for game done
    "total_travel"  : 0.0, # total movement in miles
    "total_games_done" : 0, # total game done played
    "total_time" : 0.0, # total time on server
    "total_server_sessions" : 0, # total server connects
    "total_fish_missed" :0,
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
var current_game_data : Dictionary = {
    "player_id" : 0,# store player id
    "version" : 0, # store current version
    "food" : 0, # current food
    "horn_used" : 0, #how many horn was used
    "max_player_in_session" : 0, # total player count in a server session
    "server_disconnects" : 0, # when server kills the process or restart
    "failed_disconnects" : 0, # when cant join to server
    #settings
    "master_volume" : 0.4,
    "music_volume" : 0.4,
    "sound_volume" : 0.4,
    "show_name_tags" : 1,
    ### total stats
    "GDQ" : 0.0, # time for game done
    "total_travel"  : 0.0, # total movement in miles
    "total_games_done" : 0, # total game done played
    "total_time" : 0.0, # total time on server
    "total_server_sessions" : 0, # total server connects
    "total_fish_missed" :0,
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
    current_game_data["total_time"] += delta

#################### END BASE FUNCTIONS ###########
func _on_timer_timeout() ->void:
    save_game_data()

func get_game_data_int(_key: String) -> int:
    if current_game_data.has(_key):
        return current_game_data[_key]
    else:
        return 0

func get_game_data_float(_key: String) -> float:
    if current_game_data.has(_key):
        return current_game_data[_key]
    else:
        return 0.0

func get_game_data_string(_key: String) ->String:
    if current_game_data.has(_key):
        return str(current_game_data[_key])
    else:
        return "0"
func add_game_data(_key : String, _value : float) -> void:
    if current_game_data.has(_key):
        current_game_data[_key] += _value

func add_fish(_current_fish_type : int,_reward : int) ->void:

    current_game_data["total_fish"] += _reward

    match _current_fish_type:
        0:#    "total_bausa" : 0,
            current_game_data["total_bausa"] +=_reward
            print("bausa fish updated")
            if get_game_data_int("biggest_bausa") < _reward:
                print("bausa crowd updated")
                current_game_data["biggest_bausa"]  =_reward
        1:#"total_oremo" : 0,
            current_game_data["total_oremo"] +=_reward
            print("oremo fish updated")
            if get_game_data_int("biggest_oremo") < _reward:
                print("oremo crowd updated")
                current_game_data["biggest_oremo"]  =_reward
        2:#"total_dorrie" : 0,
            current_game_data["total_dorrie"] +=_reward
            print("dorrie fish updated")
            if get_game_data_int("biggest_dorrie") < _reward:
                print("dorrie crowd updated")
                current_game_data["biggest_dorrie"]  =_reward
        3: #"total_radioactive" : 0,
            current_game_data["total_radioactive"] +=_reward
            print("radioactive fish updated")
            if get_game_data_int("biggest_radioactive") < _reward:
                print("radioactive crowd updated")
                current_game_data["biggest_radioactive"]  =_reward
        4: #"total_scarla" : 0,
            current_game_data["total_scarla"] +=_reward
            print("scarla fish updated")
            if get_game_data_int("biggest_scarla") < _reward:
                print("scarla crowd updated")
                current_game_data["biggest_scarla"]  =_reward
        5:#"total_red_lobfish" : 0,
            current_game_data["total_red_lobfish"] +=_reward
            print("red lobfish updated")
            if get_game_data_int("biggest_red_lobfish") < _reward:
                print("red lobfish crowd updated")
                current_game_data["biggest_red_lobfish"]  =_reward
        6: #"total_scarfase" : 0,
            current_game_data["total_scarfase"] +=_reward
            print("scarfase fish updated")
            if get_game_data_int("biggest_scarfase") < _reward:
                print("scarfase crowd updated")
                current_game_data["biggest_scarfase"]  =_reward
        7: #"total_deadhearth" : 0,
            current_game_data["total_deadhearth"] +=_reward
            print("deadhearth fish updated")
            if get_game_data_int("biggest_deadhearth") < _reward:
                print("deadhearth crowd updated")
                current_game_data["biggest_deadhearth"]  =_reward
        8: #"total_tangle" : 0,
            current_game_data["total_tangle"] += _reward
            print("tangle fish updated")
            if get_game_data_int("biggest_tangle") < _reward:
                print("tangle crowd updated")
                current_game_data["biggest_tangle"]  =_reward
        9: #"total_elvfish" : 0,
            current_game_data["total_elvfish"] += _reward
            print("elvfish updated")
            if get_game_data_int("biggest_elvfish") < _reward:
                print("elvfish crpwd updated")
                current_game_data["biggest_elvfish"]  =_reward
        10: # "total_amenii"
            current_game_data["total_amenii"] += _reward
            print("amenii fish updated")
            if get_game_data_int("biggest_amenii") < _reward:
                print("amenii crowd updated")
                current_game_data["biggest_amenii"]  =_reward
        _:
            print("Case Error for fish_type")
        
        
func set_game_data(_key : String, _value : Variant) ->void:
    if current_game_data.has(_key):
        current_game_data[_key]  = _value

### PERSISTENT APPLY NEW GAME DATA
func apply_game_data_from_persistent(_loaded_game_data: Dictionary) ->void:
    current_game_data =  _loaded_game_data

func save_game_data() ->void:
    PersistentData.save_game(current_game_data)

