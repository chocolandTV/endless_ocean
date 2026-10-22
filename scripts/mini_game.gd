extends Control
class_name Minigame

@export var debug_draw_catch_rect: bool = true
#Mother FishingNet
@onready var fishing_net : PanelContainer = $PanelContainer/MarginContainer/Ocean/Fishing_Mechanic
# Catched Green Texture
@onready var fishing_net_catched : TextureRect = $PanelContainer/MarginContainer/Ocean/Fishing_Mechanic/Fishing_Net_catched
@onready var caught_fish_layer : Node2D = $PanelContainer/MarginContainer/Ocean/Fishing_Mechanic/CaughtFishLayer
# fish mother
@onready var fish_mother  : Panel  = $PanelContainer/MarginContainer/Ocean/Fish_minigame_Spawner
#animation for fishy
@onready var anim : AnimationPlayer = $PanelContainer/MarginContainer/Ocean/AnimationPlayer

# const variables
const BASE_SPEED : float  = 5.0
const START_POSITION_Y : float = -627.0
const SAVE_OFFSET :float = 100

#private variables
var _fish_in_net : int = 0
var _is_running : bool = false
var _is_reel_in_pressed :bool = false
#var _debug_catch_rect: Rect2

# Called when the node enters the scene tree for the first time.
#func _ready() -> void:

#func _draw() -> void:
	#if not debug_draw_catch_rect or not _is_running:
	#	return

	#var corners := PackedVector2Array([
	#	get_global_transform().affine_inverse() * _debug_catch_rect.position,
	#	get_global_transform().affine_inverse() * (_debug_catch_rect.position + Vector2(_debug_catch_rect.size.x, 0.0)),
	#	get_global_transform().affine_inverse() * (_debug_catch_rect.position + _debug_catch_rect.size),
	#	get_global_transform().affine_inverse() * (_debug_catch_rect.position + Vector2(0.0, _debug_catch_rect.size.y))
	#])
	#draw_colored_polygon(corners, Color(1.0, 0.1, 0.1, 0.2))
	#corners.append(corners[0])
	#draw_polyline(corners, Color(1.0, 0.1, 0.1), 2.0)


# set button state
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("fishing"):
		_is_reel_in_pressed = true
	elif event.is_action_released("fishing"):
		_is_reel_in_pressed = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	# if minigame is active 
	if _is_running:
		#check animation is done - result lose
		if !anim.is_playing() and _fish_in_net == 0:
			print("Minigame: Result lose")
			_is_running = false
			# change state and send result to network
			Game_State_Manager.instance.on_request_finish_fishing(false, _fish_in_net)
		#  MOVE FISHING NET
		if _is_reel_in_pressed:
			# Check win condition
			if fishing_net.position.y < START_POSITION_Y + SAVE_OFFSET and _fish_in_net >0:
				print("Minigame: Result win with %s fish" % _fish_in_net)
				_is_running = false
				# get out minigame
				Game_State_Manager.instance.on_request_finish_fishing(true,_fish_in_net)
				#rpc call request result(count)
			fishing_net.position.y -= BASE_SPEED * anim.speed_scale
		else:
			fishing_net.position.y += BASE_SPEED/2 * anim.speed_scale
			# Cap fishing net position max range
			if fishing_net.position.y >= -209.0:
				fishing_net.position.y = -209.0


		# get rectange of fishing net
		var net_rect : Rect2 = fishing_net.get_global_rect()
		var catch_rect :Rect2 = Rect2(
			net_rect.position + Vector2(net_rect.size.x * 0.1, net_rect.size.y * 0.87),
			Vector2(net_rect.size.x * 0.8, net_rect.size.y * 0.12)
		)
		#_debug_catch_rect = catch_rect
		#queue_redraw()

		for fish: TextureRect in fish_mother.get_children():
			if catch_rect.has_point(fish.get_global_rect().get_center()):
				# get new fish
				_fish_in_net += 1
				if fish.has_method("stop_swimming"):
					fish.call("stop_swimming")
				# Keep the fish's global position and scale without PanelContainer layout
				fish.reparent(caught_fish_layer, true)
				# play catchi animation and sound
				fishing_net_catched.visible = true
		#if _fish_in_net >0:
			#print("Minigame collected % Fish", str(_fish_in_net))
		# after net is up send rpc to server and add fish amount
		
# must be cast with set_minigame_enabled(_bool : bool = true)
func start_minigame(_count : int, _type : int) ->void:
	fishing_net.position.y = START_POSITION_Y
	_is_running = true
	#reset positions / sprites
	#### COUNT FISH IN NET reset
	_fish_in_net = 0
	# start minigame dropping fishing net
	fish_mother.spawn_fishcrowd(_count, _type)
	# random speed
	var _random_speed : float = randf_range(1,3)
	anim.speed_scale =_random_speed
	# radom animation
	var _weight : float = randf_range(1,50)
	#case weight 1% prianha, 5% crazy_fish, 94% fish swim
	var _animation :String ="fish_swim"
	if _weight < 2:
		_animation = "piranha"
	if _weight < 10:
		_animation ="crazy_fish"
	anim.play(_animation)
