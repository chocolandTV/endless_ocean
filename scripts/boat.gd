extends CharacterBody2D
class_name Boat_Controller

@onready var sprite : Sprite2D = $Sprite2D
@onready var fishing_net_anim : AnimationPlayer =$Sprite2D/Fishing_Net_Anim
const SPEED : float = 200.0
const ACCELERATION_TIME : float = 2.0
const ACCELERATION : float = SPEED / ACCELERATION_TIME
const ROTATION_SPEED : float = 1.5

# set player node id to given multiplayer connector
#### IMPORTANT THIS set authority to player status, but in ready or function you have to if !is_multiplayer_authority():return
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if !is_multiplayer_authority():
		return

	Game_State_Manager.instance.set_player(self)
	# get sonar radar
	var sonar_radar: Node = get_tree().get_first_node_in_group("sonar_radar")
	if sonar_radar == null:
		push_error("Boat requires a SonarRadar node in the scene.")
		SoundManager.play_sfx("Error_Sound")
		return
	if !sonar_radar.has_method("set_player_node"):
		SoundManager.play_sfx("Error_Sound")
		push_error("SonarRadar node must implement set_player_node().")
		return
	sonar_radar.call("set_player_node", self)
	# add server session after connection to server and initialized successfully
	GameData.add_game_data("total_server_sessions",1)

func _physics_process(delta: float) -> void:
	# only move the correct characterbody2d with your multiplayer id
	if !is_multiplayer_authority():
		return

	### is minigame running disable control
	if Game_State_Manager.instance.current_game_state == Game_State_Manager.GAME_STATE.FISHING:
		return
	
	var engine_power : float  = Input.get_axis("ui_down","ui_up")
	if engine_power < 0:
		engine_power *= 0.3
	var steering : float = Input.get_axis("ui_left", "ui_right")
	if not is_zero_approx(steering):
		sprite.rotation += steering * ROTATION_SPEED * delta

	var forward : Vector2 = Vector2.UP.rotated(sprite.global_rotation)
	
	velocity = velocity.move_toward(forward * SPEED * -engine_power, ACCELERATION * delta)
	
	#tracking movement
	GameData.current_game_data["total_travel"] += velocity.length()
	move_and_slide()
