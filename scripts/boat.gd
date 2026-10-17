extends CharacterBody2D
class_name Boat_Controller
@export var fishing_ui : Control

@onready var sprite : Sprite2D = $Sprite2D

const SPEED : float = 200.0
const ACCELERATION_TIME : float = 2.0
const ACCELERATION : float = SPEED / ACCELERATION_TIME
const ROTATION_SMOOTHING : float = 2.0

# set player node id to given multiplayer connector
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if !is_multiplayer_authority():
		return
	#add player node to game state manager
	Game_State_Manager.instance.set_player(self)
	# get sonar radar
	var sonar_radar: Node = get_tree().get_first_node_in_group("sonar_radar")
	if sonar_radar == null:
		push_error("Boat requires a SonarRadar node in the scene.")
		return
	if !sonar_radar.has_method("set_player_node"):
		push_error("SonarRadar node must implement set_player_node().")
		return
	sonar_radar.call("set_player_node", self)

func _physics_process(delta: float) -> void:
	# only move the correct characterbody2d with your multiplayer id
	if !is_multiplayer_authority():
		return

	### is minigame running disable control
	if Game_UI.instance.is_minigame_running:
		return
	
	if Input.is_action_just_pressed("fishing"):
		if fishing_ui:
			fishing_ui.cast_rod()

	var direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if !direction.is_zero_approx():
		#calculate rotation
		var target_rotation : float = direction.angle() - PI / 2.0
		#
		var rotation_weight : float = 1.0 - exp(-ROTATION_SMOOTHING * delta)
		sprite.rotation = lerp_angle(sprite.rotation, target_rotation, rotation_weight)

	velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)

	move_and_slide()
