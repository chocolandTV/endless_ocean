extends Node

# signals
signal connection_changed(_connected : bool)
signal game_state_updated(state: Dictionary)
signal fishing_result_received(success : bool,message : String, reward : int)
signal fishing_session_started_received(_fishing_sessions : Dictionary)
signal fishing_session_ended_received(_success : bool, message: String)
signal boss_finished()
signal boss_spawned()
# consts
const SERVER_PORT : int = 9080
const MAX_PLAYERS: int  = 128
const DEFAULT_START_FOOD : int  = 100
const DEFAULT_BOSS_FOOD_CONDITION : int = 10000
const DEFAULT_BOSS_HEALTH : float = 100.0
const FOOD_DECAY_TIME : int = 30
const FISHING_COOLDOWN_MS : int = 1500
const BOSS_DAMAGE_COOLDOWN_MS: int = 50
const MIN_FISHING_DURATION_MS : int = 100
const MAX_FISHING_DURATION_MS: int  = 45000
const INPUT_INTERVAL_MS : int = 100
const MIN_INPUT_SAMPLES: int  = 15
const GOOD_BALANCE_RANGE : float = 15.0
const MAX_TENSION : float = 100.0

# only server executes
var is_server : bool  = false

# Base stats
var players = []
var food_by_player: Dictionary = {}
var active_fishers: Dictionary = {}
var fishing_sessions: Dictionary = {}
var last_fishing_time: Dictionary = {}
var last_boss_damage_ms: Dictionary = {}
var last_fisher_action : Dictionary = {}
var total_progress:  int = 0
var next_session_id: int  = 1
var current_boss_health : float = 100.0
# timer
var decay_timer : float = 0.0
#private debug variables 

var _is_boss_spawned: bool = false
var _server_requests : int = 0
var _server_calls : int  = 0
var _server_connects : int  = 0
var _server_errors : int =  0
var _fishing_errors : int  = 0
######################### SERVER START FUNCTION 
func start_server() -> Error:
    var peer := WebSocketMultiplayerPeer.new()
    var err:= peer.create_server(SERVER_PORT, "*")

    if err != OK:
        SoundManager.play_sfx("Error_Sound")
        push_error("Server error on start: %s" % err)
        _server_errors +=1
        return err
    
    multiplayer.multiplayer_peer = peer
    is_server = true

    if not multiplayer.peer_connected.is_connected(_on_peer_connected):
        multiplayer.peer_connected.connect(_on_peer_connected)
    
    if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
        multiplayer.peer_disconnected.connect(_on_peer_disconnected)

    print("Server initialize finished on port: %s " % SERVER_PORT)
    return OK

func connect_to_server(_url : String) -> Error:

    var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
    # create new peer
    var err:= peer.create_client(_url)
    # if error on creating client print
    if err != OK:
        SoundManager.play_sfx("Error_Sound")
        push_error("network connection failed")
        _server_errors +=1
        return err
    # stats
    _server_connects += 1

    # Multiplayer API add new peer
    multiplayer.multiplayer_peer = peer
    # disable server mode
    is_server = false
    # new secure conditon
    if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
        multiplayer.connected_to_server.connect(_on_connected_to_server)

    if not multiplayer.connection_failed.is_connected(_on_connection_failed):
        multiplayer.connection_failed.connect(_on_connection_failed)
    
    if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
        multiplayer.server_disconnected.connect(_on_server_disconnected)
    
    return OK

######## SERVER RUNNING FUNCTIONS GAME_LOOP
func _physics_process(_delta : float) ->void:
    if not is_server:
        return
    

    decay_timer +=_delta

    if decay_timer >= FOOD_DECAY_TIME:
        decay_timer = 0.0

        _decay_food()
        total_progress -= _count_players()
        if total_progress <= 0:
            total_progress = 0


# connections success signal
func _on_connected_to_server() ->void:
    connection_changed.emit(true)

# connection failed signal 
func _on_connection_failed() ->void:
    connection_changed.emit(false)

# connection on server disconnected signal
func _on_server_disconnected() ->void:
    food_by_player.clear()
    active_fishers.clear()
    fishing_sessions.clear()
    last_fishing_time.clear()
    last_boss_damage_ms.clear()
    players.clear()
    connection_changed.emit(false)

func _on_peer_connected(_id : int) ->void:
    if not is_server:
        return

    food_by_player[_id] = DEFAULT_START_FOOD
    active_fishers[_id] = false
    players.append(_id)
    _broadcast_state()

func _on_peer_disconnected(_id : int) ->void:
    if not is_server:
        return
    
    food_by_player.erase(_id)
    active_fishers.erase(_id)
    fishing_sessions.erase(_id)
    last_fishing_time.erase(_id)
    last_boss_damage_ms.erase(_id)
    players.erase(_id)
    _broadcast_state()

#client requests to begin fishing  #CHECK
@rpc("any_peer","call_remote","reliable")
func request_start_fishing(_position : Vector2) ->void:
    #only server execute
    if not is_server:
        return
    #stats
    _server_requests +=1
    #get peer id
    var sender_id : int= multiplayer.get_remote_sender_id()
    # if allready in session quit
    if fishing_sessions.has(sender_id):
        print("allready in session")
        _fishing_errors +=1
        await get_tree().create_timer(3.0).timeout
        fishing_sessions.erase(sender_id)
        return
    
    
    var now : float = Time.get_ticks_msec()
    var last_time: float =int(last_fishing_time.get(sender_id,0))

    if now - last_time < FISHING_COOLDOWN_MS:
        _fishing_errors +=1

        print("so short delay to fishing -> %s ms" % [now - last_time < FISHING_COOLDOWN_MS])
        return
    
    # decrease player food
    food_by_player[sender_id] -= 1

    var session_id :int = next_session_id
    next_session_id += 1
    # save stats
    # fish chance  1 of 100 to double
    # fish chance 1 of 10000 unique fish
    var _fishy_count : int  = randi_range(1,10 +_count_players())
    var _fish_type : int  = randi_range(0,10)
    if randi_range(1,100) >99:
        _fishy_count *= 10
    if randi_range(1, 10000)>9999:
        _fish_type = 11 #Koi baby
    
    fishing_sessions[sender_id] =  {
        "id" : session_id,
        "started_ms" : now,
        "fish_count" : _fishy_count,
        "fish_type" : _fish_type,
        "position" : _position,
    }
    active_fishers[sender_id] = true
    last_fishing_time[sender_id] = now
    #stat
    _server_calls +=1
    on_fishing_session_started.rpc_id(sender_id, fishing_sessions[sender_id])
    _broadcast_state()

#clients submits its current slider and button state
@rpc("any_peer","call_remote","unreliable")
func submit_fishing_input(session_id : int, balance : float, reeling: bool) -> void:
    if not is_server:
        return
    var sender_id : int = multiplayer.get_remote_sender_id()

    if not fishing_sessions.has(sender_id):
        _fishing_errors += 1
        return
    
    var session : Dictionary = fishing_sessions[sender_id]

    if int(session["id"]) != session_id:
        print("not same session id")
        _fishing_errors+=1
        return
    var now : float = Time.get_ticks_msec()
    var last_input: float = int(session["last_input_ms"])

    if now - last_input < INPUT_INTERVAL_MS:
        print("to short interval")
        _fishing_errors +=1
        return
    
    if not is_finite(balance) or balance < 0.0 or balance > 100.0:
        print("balance is out of nowhere")
        return
    
    var elapsed :float = float(now - int(session["started_ms"])) / 1000.0
    var phase : float  = float( session["phase"])
    var target : float = _get_target_position(elapsed, phase)
    var difference : float  = absf(balance - target)

    var tension : = float (session["tension"])

    if difference <= GOOD_BALANCE_RANGE:
        tension = maxf(0.0, tension -8.0)
        if reeling:
            session["good_samples"] = int(session["good_samples"]) +1
    elif difference <= 28.0:
        tension += 3.0
    
    else:
        tension += 7.0

    session["samples"] = int(session["samples"]+1)
    session["last_input_ms"] = now
    session["last_balance"] = balance
    session["reeling"] = reeling
    session["tension"] = clampf(tension, 0.0, MAX_TENSION)

    fishing_sessions[sender_id]  = session

    if float(session["tension"]) >= MAX_TENSION:
        _end_fishing(sender_id, false, "The fish escaped.",0)

# client send name for last fishing
@rpc("any_peer","call_remote","reliable")
func request_last_fishing(_amount: int, _name : String)->void:
    if not is_server:
        return
    #stats
    _server_requests +=1
    last_fisher_action = {
        "name" : _name,
        "fish_count" : _amount
    }
@rpc("authority","call_local", "reliable")
func on_boss_spawned() ->void:
    boss_spawned.emit()

@rpc("any_peer","call_remote", "reliable")
func request_boss_damage() ->void:
    if not is_server:
        return
    _apply_boss_damage(multiplayer.get_remote_sender_id())

func request_boss_damage_from_server(sender_id: int) -> void:
    if not is_server:
        return
    _apply_boss_damage(sender_id)

func _apply_boss_damage(sender_id: int) -> void:
    print("boss damaged")
    if not _is_boss_spawned:
        return
    if not players.has(sender_id):
        return
    if current_boss_health <= 0:
        return

    var now: int = Time.get_ticks_msec()
    var last_hit_ms: int = int(last_boss_damage_ms.get(
        sender_id,
        now - BOSS_DAMAGE_COOLDOWN_MS
    ))
    if now - last_hit_ms < BOSS_DAMAGE_COOLDOWN_MS:
        return

    last_boss_damage_ms[sender_id] = now
    current_boss_health = maxf(current_boss_health - 1.0, 0.0)
    
    if current_boss_health == 0:
        print("Boss finished Congratulation")
        _is_boss_spawned = false
        total_progress = 0
        receive_boss_finished.rpc()

        _server_calls +=1
    _broadcast_state()

#client asks to finish the current fishing attempt
@rpc("any_peer","call_remote","reliable")
func request_finish_fishing(_fishing_info : Dictionary)->void:
    if not is_server:
        return
    #stats
    _server_requests +=1
    var sender_id: int = multiplayer.get_remote_sender_id()

    if not fishing_sessions.has(sender_id):
        _fishing_errors +=1
        return
    
    var session: Dictionary = fishing_sessions[sender_id]
    if _fishing_info.has("session_id"):
        if int(session["id"]) != _fishing_info["session_id"]:
            _fishing_errors +=1
            print("not same session id")
            return
    
    var elapsed_ms: float = Time.get_ticks_msec() - int(session["started_ms"])
    
    if elapsed_ms < MIN_FISHING_DURATION_MS:
        _fishing_errors +=1
        print("to short to finish fishing")
        return

    if elapsed_ms > MAX_FISHING_DURATION_MS:
        _fishing_errors +=1
        _end_fishing(sender_id, false, "The fish escaped.",0)
        return
    ################## REWARD PLAYER #####################
    var reward : int = 0
    if _fishing_info.has("success"):
        if _fishing_info["success"]:
            #reward calculation

            if _fishing_info.has("fish_count"):
                reward = _fishing_info["fish_count"]
            else:
                reward = randi_range(1,20)

            ##group bonus
            #reward += _count_players()

            food_by_player[sender_id] += reward
            total_progress += reward

            if (total_progress >= DEFAULT_BOSS_FOOD_CONDITION) and !_is_boss_spawned:
                _is_boss_spawned = true
                current_boss_health = DEFAULT_BOSS_HEALTH
                print("Amena Koi approaches!")
                _broadcast_state()
                on_boss_spawned.rpc()

            _end_fishing(sender_id,_fishing_info["success"],"Fish caught!", reward)
        else:
            #Failed
            _end_fishing(sender_id,_fishing_info["success"], "Fish escaped!", reward)
    else:
        #fishing info incomplete
        print("Network: Fishing_Info incomplete")
        _end_fishing(sender_id,_fishing_info["success"], "Fish escaped!",0)

func _get_target_position(elapsed : float, phase: float) ->float:
    # deterministic movement function on client and server
    var movement: float= ( 30.0 * sin(elapsed * 1.2 + phase)
    + 10.0 * sin(elapsed * 2.7 + phase * 1.7)
    )
    return clampf(50.0 + movement, 10.0, 90.0)
# get current acive fishers
func _count_players() ->int:  
    return players.size()


############################# IMPORTANT RESULT
# end fishing with print and result
func _end_fishing(sender_id: int, success : bool, message : String, _reward : int) ->void:
    # clear current session for client
    fishing_sessions.erase(sender_id)

    if active_fishers.has(sender_id):
        active_fishers[sender_id] =  false
    
    #stat
    _server_calls +=1
    on_fishing_result.rpc_id(sender_id, success, message, _reward)
    _broadcast_state()


@rpc("authority","call_remote","reliable")
func on_fishing_session_started(_fishing_sessions : Dictionary)->void:
    fishing_session_started_received.emit(_fishing_sessions)

@rpc("authority","call_remote", "reliable")
func on_fishing_session_ended(success : bool, message: String) ->void:
    fishing_session_ended_received.emit(success, message)

# SERVER FUNCTION FOR SIGNAL TO FISHING_RESULT_RECEIVED
@rpc("authority","call_remote", "reliable")
func on_fishing_result(success : bool,message : String, reward : int) ->void:
    fishing_result_received.emit(success, message, reward)

# SERVER FUNCTION FOR SIGNAL TO GAME_STATE_UPDATED
@rpc("authority","call_remote", "reliable")
func receive_state(state : Dictionary) ->void:
    game_state_updated.emit(state)
    
@rpc("authority","call_local","reliable")
func receive_boss_finished() ->void:
    boss_finished.emit()
#### BASE DECAY FOOD FUNCTION OVER TIME
func _decay_food() ->void:
    for player_id in food_by_player.keys():
        food_by_player[player_id] -= 1
    
#### PUBLIC BROADCAST INFORMATIONS ABOUT THE PROGRESS FROM ALL PLAYERS
func _broadcast_state() ->void:
    var state :Dictionary = {
        "food" : food_by_player.duplicate(),
        "progress" : total_progress,
        "boss_spawned" : _is_boss_spawned,
        "active_fishers" : players.size(),
        "last_fisher" : last_fisher_action.duplicate(),
        "boss_health" : current_boss_health
    }
    receive_state.rpc(state)
    #stats
    _server_calls +=1
    #print("Server: %s Players connected since start, current(%s) Players,  Server_Calls: %s, Server_Requests: %s" % [_server_connects, players.size(), _server_calls,_server_requests])
    #print("Server Errors: %s Connection errors, %s fishing errors" %[_server_errors, _fishing_errors])