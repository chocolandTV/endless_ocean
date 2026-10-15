extends Control
signal minigame_finished(_success : bool, accuracy : float)
#export variables for balancing
@export var good_balance_range  :float = 15.0
@export var danger_balance_Range: float = 28.0
@export var max_tension : float = 100.0
@export var reel_speed: float = 24.0
@export var tension_growth : float = 32.0 # rate
@export var tension_recovery: float =  20.0
#onready variables for ui elements
@onready var target_label : Label  =$MarginContainer/PanelContainer/VBoxContainer/Head_Info
@onready var balance_slider : HSlider = $MarginContainer/PanelContainer/VBoxContainer/Balance_Hslider
@onready var tension_bar : ProgressBar = $MarginContainer/PanelContainer/VBoxContainer/Tension_Bar
@onready var catch_progress : ProgressBar = $MarginContainer/PanelContainer/VBoxContainer/Catch_Progress
@onready var status_label : Label = $MarginContainer/PanelContainer/VBoxContainer/Status_Label
@onready var reel_button : Button = $MarginContainer/PanelContainer/VBoxContainer/Button

# private variables 
var is_reel_button_pressed : bool = false
var target_position :float  =50.0
var tension : float = 0.0
var progress : float = 0.0
var is_running: bool = false
var finished : bool = false
var accuracy_sum : float = 0.0
var accuracy_samples : int  = 0

# network variables
var current_session_id: int = -1
var fish_phase: float = 0.0
var input_timer: float = 0.0
var fishing_elapsed: float = 0.0
var catch_confirmation_requested: bool = false


func _ready() -> void:
	balance_slider.min_value = 0
	balance_slider.max_value = 100
	balance_slider.value = 50

	tension_bar.max_value = max_tension
	catch_progress.max_value = 100

	reel_button.button_down.connect(_on_reel_down)
	reel_button.button_up.connect(_on_reel_up)
	#network signals
	Network.fishing_session_started_received.connect(_on_fishing_session_started)
	Network.fishing_session_ended_received.connect(_on_fishing_session_ended)
	Network.fishing_result_received.connect(_on_fishing_result_received)

func _physics_process(_delta: float) -> void:

	if not is_running or finished:
		return
	target_position = clampf(
		50.0
		+ 30.0 * sin(fishing_elapsed * 1.2 + fish_phase)
		+ 10.0 * sin(fishing_elapsed * 2.7 + fish_phase * 1.7),
		10.0,
		90.0
	)

	var _difference : float = absf(float(balance_slider.value) - target_position)

	target_label.text = "Fisch-Zug: %.0f" % target_position

	if _difference <= good_balance_range:
		if is_reel_button_pressed:
			progress += reel_speed * _delta

		tension -=tension_recovery * _delta
		status_label.text = "Perfect, reeeeeeeeeel iiiiiiiiin"
	
	elif _difference <= danger_balance_Range:
		if is_reel_button_pressed:
			progress += reel_speed * 0.3 * _delta

		tension+= tension_growth * 0.35 * _delta
		status_label.text  ="Caution, keep balance!"
	
	else:
		tension += tension_growth * _delta

		if is_reel_button_pressed:
			progress -= reel_speed * 0.5 * _delta

		status_label.text = "To much pull, counteract it"
	
	tension = clampf(tension, 0.0, max_tension)
	progress = clampf(progress, 0.0, 100.0)

	accuracy_sum += 1.0 - clampf(_difference / 50.0,0.0,1.0)
	accuracy_samples += 1

	tension_bar.set_value_no_signal( tension)
	catch_progress.set_value_no_signal(progress)

	if tension >= max_tension:
		_finished(false)
	elif progress >= 100.0 and not catch_confirmation_requested:
		catch_confirmation_requested = true
		request_catch_confirmation()

	fishing_elapsed += _delta

	_send_fishing_input(_delta)


func _start_minigame() ->void:
	target_position = 50.0

	tension = 0.0
	progress = 0.0
	accuracy_sum = 0.0
	accuracy_samples = 0
	catch_confirmation_requested = false

	is_reel_button_pressed =false
	is_running = true
	finished = false

	balance_slider.set_value_no_signal(50.0)
	tension_bar.set_value_no_signal(0)
	catch_progress.set_value_no_signal(0)

	status_label.text = "Fish catched, hold the balance"
	#reel_button.disabled = false
############### FINISH SIGNAL CONNECT
func _on_fishing_result_received(_success : bool, _amount : int)->void:
	if _success:

		#play animation amount 
		print("Fishing_UI: You catched %s fish", _amount)
		_finished(true)
	else:

		print("Fishing_UI: The fish escaped.")
		_finished(false)

func _on_reel_down() ->void:
	if is_running and not finished:
		is_reel_button_pressed = true

func _on_reel_up() ->void:
	is_reel_button_pressed = false

func _finished(_result : bool) ->void:
	if finished:
		return
	
	finished = true

	is_running = false
	is_reel_button_pressed = false
	#reel_button.disabled = true

	# genauigkeit
	var _accuracy: float = 0.0

	if accuracy_samples > 0:
		_accuracy = accuracy_sum / float(accuracy_samples)

	if _result:
		status_label.text ="Catched."
	else:
		status_label.text = "The Fish has escaped."

	minigame_finished.emit(_result, _accuracy)

func request_catch_confirmation() ->void:
	if current_session_id < 0:
		return
	Network.request_finish_fishing.rpc_id(1,current_session_id)

func cast_rod() ->void:
	if current_session_id == -1:
		print("Fishing_UI: cast network request")
		Network.request_start_fishing.rpc_id(1)
	else:
		print("Fishing_UI: allready fishing")

func _on_fishing_session_started(session_id:int, phase : float)->void:
	current_session_id = session_id
	fish_phase = phase
	fishing_elapsed = 0.0
	input_timer = 0.0
	#START MINIGAME
	_start_minigame()

func _on_fishing_session_ended(_success : bool, message: String) ->void:
	current_session_id = -1
	is_running = false
	is_reel_button_pressed = false
	#reel_button.disabled = true

	status_label.text = message

func _send_fishing_input(_delta : float) ->void:
	if current_session_id < 0:
		return

	input_timer += _delta

	if input_timer < 0.1:
		return
	input_timer = 0.0
	# submit fishing input, will cancel everytime something went wrong session id, multi fishing, abuse mechanic
	Network.submit_fishing_input.rpc_id(1, current_session_id, float(balance_slider.value),is_reel_button_pressed)
