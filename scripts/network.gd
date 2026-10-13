extends Node

# signals
signal connection_changed(_connected : bool)
signal game_state_updated(state:  Dictionary)
signal fishing_result_received(_success : bool, amount : int)

# consts
const SERVER_PORT : int = 9080
const MAX_PLAYERS: int  = 128
const DEFAULT_START_FOOD : int  = 100
const DEFAULT_BOSS_FOOD_CONDITION : int = 1000
# only server executes
var is_server : bool  = false

# Base stats
var food_by_player: Dictionary = {}
var active_fishers: Dictionary = {}
var total_progress:  int = 0
var boss_spawned : bool = false

# timer
var decay_timer : float = 0.0

######################### SERVER START FUNCTION 
func start_server() -> Error:
    var peer := WebSocketMultiplayerPeer.new()
    var err:= peer.create_server(SERVER_PORT, "*")

    if err != OK:
        push_error("Server error on start: %s" % err)
        return err
    
    multiplayer.multiplayer_peer = peer
    is_server = true

    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

    print("Server initialize finished on port: ", SERVER_PORT)
    return OK

func connect_to_server(_url : String) -> Error:

    var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
    # create new peer
    var err:= peer.create_client(_url)
    # if error on creating client print
    if err != OK:
        push_error("network connection failed")
        return err

    # Multiplayer API add new peer
    multiplayer.multiplayer_peer = peer
    # disable server mode
    is_server = false

    return OK

######## SERVER RUNNING FUNCTIONS GAME_LOOP
func _process(_delta : float) ->void:
    if not is_server:
        return
    

    decay_timer +=_delta

    if decay_timer >= 1:
        decay_timer = 0.0

        _decay_food()
        _broadcast_state()

    
func _on_peer_connected(_id : int) ->void:
    if not is_server:
        return

    food_by_player[_id] = DEFAULT_START_FOOD
    active_fishers[_id] = false
    _broadcast_state()

func _on_peer_disconnected(_id : int) ->void:
    if not is_server:
        return
    
    food_by_player.erase(_id)
    active_fishers.erase(_id)
    _broadcast_state()

# client request - server result
@rpc("any_peer","call_remote","reliable")#crazy magic high level multiplayer
func request_fish() -> void:

    if not is_server:
        return
    
    # get sender id from remote procedure call # arma  reference remoteExec 
    var _sender_id := multiplayer.get_remote_sender_id()

    # if client is fisherman
    if not food_by_player.has(_sender_id):
        return
    # is active fisher
    if not active_fishers.get(_sender_id, false):
        print("Error: Player is not active")
        return

    #reward
    var _reward : int  = randi_range(0,10) * active_fishers.size()
    food_by_player[_sender_id] += _reward
    print("Server: Player %s collect %s Food, Anema Koi needs %s Food left" % [_sender_id, _reward, DEFAULT_BOSS_FOOD_CONDITION - total_progress])
  
    ##add to global count
    total_progress += _reward

    # if boss_condition cleared, spawn amena koi
    if total_progress >= DEFAULT_BOSS_FOOD_CONDITION and not boss_spawned:
        boss_spawned = true
        print("Amena Koi approaches")
    
    # call this function from server with client id
    on_fishing_result.rpc_id(_sender_id, true, _reward)
    _broadcast_state()

@rpc("any_peer","call_remote","reliable")
func set_fishing(_active : bool) ->void:

    if not is_server:
        return
    
    var _sender_id:= multiplayer.get_remote_sender_id()

    if not active_fishers.has(_sender_id):
        print("Error: Player is not active")
        return
    
    active_fishers[_sender_id] = true
    _broadcast_state()

######### SERVER REMOTE CALL TO SPECIFIC CLIENT
@rpc("authority","call_remote","reliable")
func on_fishing_result(_success : bool, _amount :int) ->void:
    fishing_result_received.emit(_success, _amount)

@rpc("authority","call_remote","reliable")
func receive_state(_state: Dictionary)->void:
    game_state_updated.emit(_state)

### Serverside functions
func _decay_food() ->void:
    # every player loose food # later if food <= 0 fisher licence disabled
    for player_id in food_by_player.keys():
        food_by_player[player_id] = max(
            0,
            int(food_by_player[player_id]) -1
        )
func _broadcast_state() ->void: 
    #create a list and send to clients
    var _state := {
        "food" : food_by_player.duplicate(),
        "progress" : total_progress,
        "boss_spawned" : boss_spawned,
        "active_fishers" : active_fishers.duplicate()
    }
    receive_state.rpc(_state)
    game_state_updated.emit(_state)