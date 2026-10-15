extends Node

# signals
signal connection_changed(_connected : bool)
signal game_state_updated(state:  Dictionary)
signal fishing_result_received(_success : bool, amount : int)
signal fishing_session_started_received(_session_id: int, phase : float)
signal fishing_session_ended_received(_success : bool, message: String)


# consts
const SERVER_PORT : int = 9080
const MAX_PLAYERS: int  = 128
const DEFAULT_START_FOOD : int  = 100
const DEFAULT_BOSS_FOOD_CONDITION : int = 1000

const FOOD_DECAY_PER_SECOND : int = 1
const FISHING_COOLDOWN_MS : int = 1500
const MIN_FISHING_DURATION_MS : int = 3000
const MAX_FISHING_DURATION_MS: int  = 45000
const INPUT_INTERVAL_MS : int = 100
const MIN_INPUT_SAMPLES: int  = 15
const GOOD_BALANCE_RANGE : float = 15.0
const MAX_TENSION : float = 100.0

# only server executes
var is_server : bool  = false

# Base stats
var food_by_player: Dictionary = {}
var active_fishers: Dictionary = {}
var fishing_sessions: Dictionary = {}
var last_fishing_time: Dictionary = {}

var total_progress:  int = 0
var boss_spawned : bool = false
var next_session_id: int  = 1

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

    if not multiplayer.peer_connected.is_connected(_on_peer_connected):
        multiplayer.peer_connected.connect(_on_peer_connected)
    
    if not multiplayer.peer_disconnected.is_connected(_on_peer_disconnected):
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
    # new secure conditon
    if not multiplayer.connected_to_server.is_connected(_on_connected_to_server):
        multiplayer.connected_to_server.connect(_on_connected_to_server)

    if not multiplayer.connection_failed.is_connected(_on_connection_failed):
        multiplayer.connection_failed.connect(_on_connection_failed)
    
    if not multiplayer.server_disconnected.is_connected(_on_server_disconnected):
        multiplayer.server_disconnected.connect(_on_server_disconnected)
    
    return OK

######## SERVER RUNNING FUNCTIONS GAME_LOOP
func _process(_delta : float) ->void:
    if not is_server:
        return
    

    decay_timer +=_delta

    if decay_timer >= FOOD_DECAY_PER_SECOND:
        decay_timer = 0.0

        _decay_food()
        _broadcast_state()

# connections success signal
func _on_connected_to_server() ->void:
    connection_changed.emit(true)

# connection failed signal 
func _on_connection_failed() ->void:
    connection_changed.emit(false)

# connection on server disconnected signal
func _on_server_disconnected() ->void:
    connection_changed.emit(false)

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
    fishing_sessions.erase(_id)
    last_fishing_time.erase(_id)
    _broadcast_state()


#client requests to begin fishing
@rpc("any_peer","call_remote","reliable")
func request_start_fishing() ->void:
    if not is_server:
        return
    
    var sender_id : int= multiplayer.get_remote_sender_id()

    if not food_by_player.has(sender_id):
        return
    
    if int(food_by_player[sender_id] <= 0):
        _send_session_message(sender_id, false, "Not enough food.")
        return
    
    if fishing_sessions.has(sender_id):
        return
    
    var now : float = Time.get_ticks_msec()
    var last_time: float =int(last_fishing_time.get(sender_id,0))

    if now - last_time < FISHING_COOLDOWN_MS:
        _send_session_message(sender_id, false, "Please wait.")
        return
    
    var session_id :int = next_session_id
    next_session_id += 1

    # the phase defines the target motion for this session
    var phase :float = randf_range(0.0,TAU)

    fishing_sessions[sender_id] =  {
        "id" : session_id,
        "started_ms" : now,
        "last_input_ms" : 0,
        "samples" : 0,
        "good_samples" : 0,
        "tension" : 0.0,
        "phase" : phase,
        "last_balance" : 50.0,
        "reeling" : false
    }
    active_fishers[sender_id] = true
    last_fishing_time[sender_id] = now

    on_fishing_session_started.rpc_id(sender_id, session_id, phase)
    _broadcast_state()

#clients submits its current slider and button state
@rpc("any_peer","call_remote","unreliable")
func submit_fishing_input(session_id : int, balance : float, reeling: bool) -> void:
    if not is_server:
        return
    var sender_id : int = multiplayer.get_remote_sender_id()

    if not fishing_sessions.has(sender_id):
        return
    
    var session : Dictionary = fishing_sessions[sender_id]

    if int(session["id"]) != session_id:
        print("not same session id")
        return
    var now : float = Time.get_ticks_msec()
    var last_input: float = int(session["last_input_ms"])

    if now - last_input < INPUT_INTERVAL_MS:
        print("to short interval")
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
        _end_fishing(sender_id, false, "The fish escaped.")

    
#client asks to finish the current fishing attempt
@rpc("any_peer","call_remote","reliable")
func request_finish_fishing(session_id : int)->void:
    if not is_server:
        return
    var sender_id: int = multiplayer.get_remote_sender_id()

    if not fishing_sessions.has(sender_id):
        return
    
    var session: Dictionary = fishing_sessions[sender_id]

    if int(session["id"]) != session_id:
        print(" not same session id")
        return
    
    var elapsed_ms: float = Time.get_ticks_msec() - int(session["started_ms"])
    
    if elapsed_ms < MIN_FISHING_DURATION_MS:
        print("to short to finish fishing")
        return

    if elapsed_ms > MAX_FISHING_DURATION_MS:
        _end_fishing(sender_id, false, "The fish escaped.")
        return
    
    var samples : int = int(session["samples"])
    var good_samples : int  = int(session["good_samples"])

    if samples < MIN_INPUT_SAMPLES:
        _end_fishing(sender_id, false, "Not enough fishing input")
        return

    #samples must be balanced while reeling
    var accuracy : float = float(good_samples) / float (samples)
    if accuracy < 0.6:
        _end_fishing(sender_id,false,"The fish escaped.")
        return
    
    var active_count : int  = _count_active_fishers()
    var reward : int = randi_range(1,20)

    #group bonus
    var bonus_multiplier : float = 1.0 + minf(
        maxf(float(active_count -1), 0.0) * 0.1,
        0.50)

    reward = int(round(float(reward) * bonus_multiplier))

    food_by_player[sender_id] += reward
    total_progress += reward

    print("Player %s collected %s food. Boss needs $s more." %[sender_id,reward,DEFAULT_BOSS_FOOD_CONDITION- total_progress])

    if (total_progress >= DEFAULT_BOSS_FOOD_CONDITION and not boss_spawned):
        boss_spawned = true
        print("Amena Koi approaches!")

    _end_fishing(sender_id,true,"Fish caught!")
    on_fishing_result.rpc_id(sender_id,true, reward)
    _broadcast_state()

func _get_target_position(elapsed : float, phase: float) ->float:
    # deterministic movement function on client and server
    var movement:= ( 30.0 * sin(elapsed * 1.2 + phase)
    + 10.0 * sin(elapsed * 2.7 + phase * 1.7)
    )
    return clampf(50.0 + movement, 10.0, 90.0)
# get current acive fishers
func _count_active_fishers() ->int:
    var count: int  = 0

    for peer_id in active_fishers.keys():
        if bool(active_fishers[peer_id]):
            count += 1
        
    return count

# end fishing with print and result
func _end_fishing(sender_id: int, success : bool, message : String) ->void:
    # clear current session for client
    fishing_sessions.erase(sender_id)

    if active_fishers.has(sender_id):
        active_fishers[sender_id] =  false
    
    if sender_id > 0:
        on_fishing_session_ended.rpc_id(sender_id, success, message)

    _broadcast_state()

func _send_session_message(sender_id,success : bool, message : String) ->void:
    on_fishing_session_ended.rpc_id(sender_id, success, message)


@rpc("authority","call_remote","reliable")
func on_fishing_session_started(session_id : int, phase : float)->void:
    fishing_session_started_received.emit(session_id, phase)

@rpc("authority","call_remote", "reliable")
func on_fishing_session_ended(success : bool, message: String) ->void:
    fishing_session_ended_received.emit(success, message)

@rpc("authority","call_remote", "reliable")
func on_fishing_result(success : bool, amount : int) ->void:
    fishing_result_received.emit(success, amount)

@rpc("authority","call_remote", "reliable")
func receive_state(state : Dictionary) ->void:
    game_state_updated.emit(state)

func _decay_food() ->void:
    for player_id in food_by_player.keys():
        food_by_player[player_id] -= FOOD_DECAY_PER_SECOND
    
func _broadcast_state() ->void:
    var state :Dictionary = {
        "food" : food_by_player.duplicate(),
        "progress" : total_progress,
        "boss_spawned" : boss_spawned,
        "active_fishers" : active_fishers.duplicate()
    }
    receive_state.rpc(state)
    game_state_updated.emit(state)