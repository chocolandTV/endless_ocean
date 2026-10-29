extends Node
const PERSISTENT_DATA_PATH : String = "user://persistent.data"
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

func save_game(_data : Dictionary) ->void:
    #create file
    var _file := FileAccess.open(PERSISTENT_DATA_PATH, FileAccess.WRITE)

    #check if _file exist
    if _file != null:
        # save data
        _file.store_var(_data)
        # close file
        _file.close()
        print("Persistent_Data: Game saved.")
    
func load_game() ->void:
    #load file
    var _loaded_file := FileAccess.open(PERSISTENT_DATA_PATH, FileAccess.READ)
    #check if loaded exist
    if _loaded_file:
        var _new_data = _loaded_file.get_var()
    #close fileaccess
    _loaded_file.close()
    print("Persistent_Data: Game loaded.")

func reset_game_data() ->void:
    # save game with default settings
    save_game(default_game_data)
    
    print("Persistent_Data : Reset Game Data")