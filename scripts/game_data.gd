extends Node
@onready var _timer : Timer = $Timer

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
    "total_Bausa" : 0,
	"total_Oremo" : 0,
	"total_Dorrie" : 0,
	"total_Radioactive Fish" : 0,
	"total_Scarla" : 0,
	"total_Red_Lobfish" : 0,
	"total_Scarfase" : 0,
	"total_Deadhearth" : 0,
	"total_Tangle" : 0,
	"total_Elvfish" : 0
}
func _ready() -> void:
    _timer.timeout.connect(_on_timer_timeout)
    PersistentData.load_game()

func _on_timer_timeout() ->void:
    save_game_data()

func add_game_data(_key : String, _value : float) -> void:
    if _game_data.has(_key):
        _game_data[_key] += _value

func set_game_data(_key : String, _value : float) ->void:
    if _game_data.has(_key):
        _game_data[_key]  = _value

func save_game_data() ->void:
    PersistentData.save_game(_game_data)

