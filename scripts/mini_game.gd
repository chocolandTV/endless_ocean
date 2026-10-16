extends Control
class_name Minigame
#Mother FishingNet
@onready var fishing_net : PanelContainer = $PanelContainer/MarginContainer/Ocean/Fishing_Mechanic
# Catched Green Texture
@onready var fishing_net_catched : TextureRect = $PanelContainer/MarginContainer/Ocean/Fishing_Mechanic/Fishing_Net_catched
# fish mother
@onready var fish_mother  : Panel  = $PanelContainer/MarginContainer/Ocean/Fish_minigame_Spawner
#animation for fishy
@onready var anim : AnimationPlayer = $PanelContainer/MarginContainer/Ocean/AnimationPlayer
const BASE_SPEED : float  = 5.0
const START_POSITION_Y : float = -627.0
const BASE_OFFSET_MIDDLE_POINT : Vector2= Vector2(256, 2048)

var _is_running : bool = false
var _result : bool  = false
var _is_reel_out_pressed :bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stat_minigame(3)


# set button state
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fishing"):
		_is_reel_out_pressed = true
	elif event.is_action_released("fishing"):
		_is_reel_out_pressed = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# if minigame is active 
	if _is_running:
		#####  MOVE FISHING NET
		if !_is_reel_out_pressed:
			fishing_net.position.y += BASE_SPEED/2
			# Cap fishing net position max range
			if fishing_net.position.y >= -209.0:
				fishing_net.position.y = -209.0
		else:
			fishing_net.position.y -= BASE_SPEED

		#### COUNT FISH IN NET
		var _fish_in_net : int = 0
		for x in fish_mother.get_children():
			print("Minigame: Fish distance : %", x.global_position.distance_to(fishing_net.global_position + BASE_OFFSET_MIDDLE_POINT))
			if x.global_position.distance_to(fishing_net.global_position + BASE_OFFSET_MIDDLE_POINT * scale) < 100:
				# get new fish
				_fish_in_net += 1
				#attach fish to net
				fishing_net.add_child(x)
				# play catchi animation and sound
				fishing_net_catched.visible = true
		if _fish_in_net >0:
			print("Minigame collected % Fish", str(_fish_in_net))
		# after net is up send rpc to server and add fish amount

# must be cast with set_minigame_enabled(_bool : bool = true)
func stat_minigame(_count : int) ->void:
	fishing_net.position.y = START_POSITION_Y
	_is_running = true
	#reset positions / sprites

	# start minigame dropping fishing net
	fish_mother. spawn_fishcrowd(_count)
	anim.play("fish_swim")