extends Node
class_name Game_State_Manager
## THIS SCRIPT HANDLES GAMESTATE AND ALL NETWORK REQUEST AND RECEIVES
# signals
signal minigame_finished(_result : bool, fish_count : int, time : float)
signal game_paused(_bool : bool)
signal boss_spawned(_position : Vector2)

enum GAME_STATE {
    MENU = 0,
    OVERWORLD = 1,
    FISHING = 2,
    BOSS = 3,
    PAUSED = 4
}
@export var minigame_ui : Control

# singleton
static var instance : Game_State_Manager = null
# public variables
var current_game_state : GAME_STATE = GAME_STATE.OVERWORLD
var last_game_state : GAME_STATE = GAME_STATE.MENU
var player_controls_enabled : bool = true

# private variables
# minigame variables
var current_session_id : int = -1
var current_food : int = 0
var _fishing_session : Dictionary  ={}
var _player_node : Node2D = null
#stats
var stat_total_fish_catched : int = 0
var stat_total_fish_escaped : int = 0
var stat_total_food_collected : int = 0
var stat_total_fishing_sesions : int = 0
var stat_highest_fish_crowd : int = 0
var stat_playtime : float = 0
var stat_max_online_player: int  = 0
var stat_logged_distance : float = 0
var stat_unlocked_skins : int = 0

func _ready() -> void:
    if instance == null:
        instance = self
    #network signals
    Network.fishing_session_started_received.connect(_on_fishing_session_started)
    Network.fishing_session_ended_received.connect(_on_fishing_session_ended)
    Network.fishing_result_received.connect(_on_fishing_result_received)

# input if fishing in overworld is pressed
func _physics_process(_delta: float) -> void:
    if Input.is_action_just_pressed("fishing") and current_game_state == GAME_STATE.OVERWORLD:
        on_fishing_button_pressed_in_overworld()

func set_player(_node : Node2D)->void:
    _player_node = _node


#### NETWORK
#if fishing button is pressed in overworld ->request fishing to start
func on_fishing_button_pressed_in_overworld() -> void:
    #get player pos and secure with zero vector
    var _position : Vector2 = Vector2.ZERO
    if _player_node:
        _position = _player_node.global_position

    Network.request_start_fishing.rpc_id(1,_position)

#if fishing is finished request to get result
func on_request_finish_fishing(_success : bool, _amount : int)->void:
    # take care if client is current fishing
    if current_game_state == GAME_STATE.FISHING:
        # get server result
        var _fishing_info : Dictionary = {
            "session_id" : current_session_id,
            "success" : _success,
            "fish_count" : _amount
        }
        Network.request_finish_fishing.rpc_id(1,_fishing_info)
    else:
        print("Gamestate_manager: Error, client is not fishing yet")

#### on fishing started signal connect
func _on_fishing_session_started(fishing_session : Dictionary)->void:
    current_session_id = fishing_session.get("id", 1)
    _fishing_session = fishing_session
    #change gamestate
    last_game_state = current_game_state
    current_game_state = GAME_STATE.FISHING
    ## print dictionary
    print("Fishing_Session: ", fishing_session)
   	#START MINIGAME
    minigame_ui.show()
    #disable player controls
    player_controls_enabled = false
    #start mingame 
    minigame_ui.start_minigame(fishing_session.get("fish_count", 1))

# on fishing ended signal connect 
func _on_fishing_session_ended(_success : bool, message: String) ->void:
    current_session_id = -1
    # hide minigame
    minigame_ui.hide()
    #enable player controls
    player_controls_enabled = true
    #set gamestate
    last_game_state = current_game_state
    current_game_state =  GAME_STATE.OVERWORLD
    #if _success play animation on player
    #else  troll player fishy animation
    print("Fishing finished : ", message)


func _on_fishing_result_received(_success : bool, _message : String, _reward : int)->void:
    if _success:
		#play animation amount 
        print("Fishing_UI: You catched %s fish", _reward)
        minigame_finished.emit(true, _reward, Time.get_ticks_msec())
        #Save last success fisher
        Network.request_last_fishing(_reward, _player_node.name)

    else:
        print("Fishing_UI: The fish escaped.")
        minigame_finished.emit(false, _reward, Time.get_ticks_msec())

    #stop minigame client side
    _on_fishing_session_ended(_success, _message)