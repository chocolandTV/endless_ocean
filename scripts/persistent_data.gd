extends Node
signal persistent_data_loaded()
signal persistent_data_saved()

const PERSISTENT_DATA_PATH : String = "user://persistent.data"

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
    persistent_data_saved.emit()
func load_game() ->void:
    #load file
    var _loaded_file := FileAccess.open(PERSISTENT_DATA_PATH, FileAccess.READ)
    #check if loaded exist
    if _loaded_file:
        var _new_data = _loaded_file.get_var()
    
        #try to assign game_data
        GameData.apply_game_data_from_persistent(_new_data)
        #close fileaccess
        _loaded_file.close()
        print("Persistent_Data: Game loaded.")
    else:
        print("There is no Data to Load.")
    persistent_data_loaded.emit()
func reset_game_data() ->void:
    # save game with default settings
    save_game(GameData.default_game_data)
    
    
    print("Persistent_Data : Reset Game Data")