extends Control
signal minigame_finished(_success : bool, accuracy : float)

@export var target_speed :float = 24.0
@export var good_balance_range  :float = 12.0
@export var danger_balance_Range: float = 224.0
@export var max_tension : float = 100.0
@export var reel_speed: float = 24.0
@export var tension_growth : float = 32.0 # rate
@export var tension_recovery: float =  20.0

@onready var target_label : Label  =$MarginContainer/PanelContainer/VBoxContainer/Head_Info
@onready var balance_slider : HSlider = $MarginContainer/PanelContainer/VBoxContainer/Balance_Hslider
@onready var tension_bar : ProgressBar = $MarginContainer/PanelContainer/VBoxContainer/Tension_Bar
@onready var catch_progress : ProgressBar = $MarginContainer/PanelContainer/VBoxContainer/Catch_Progress
@onready var status_label : Label = $MarginContainer/PanelContainer/VBoxContainer/Status_Label
@onready var reel_button : Button = $MarginContainer/PanelContainer/VBoxContainer/Button
# private variables 
var is_reel_button_pressed : bool = false
var target_position :float  =50.0
var target_direction : float = 1.0
var tension : float = 0.0
var progress : float = 0.0
var is_running: bool = false
var finished : bool = false
var accuracy_sum : float = 0.0
var accuracy_samples : int  = 0

func _ready() -> void:
	balance_slider.min_value = 0
	balance_slider.max_value = 100
	balance_slider.value = 50

	tension_bar.max_value = max_tension
	catch_progress.max_value = 100

	reel_button.button_down.connect(_on_reel_down)
	reel_button.button_up.connect(_on_reel_up)
	_start_minigame()

func _physics_process(_delta: float) -> void:
	if not is_running or finished:
		return
	#fish movement
	target_position += target_direction * target_speed * _delta
	
	if target_position > 90.0:
		target_position= 90.0
		target_direction = -1.0
	elif target_position <10.0:
		target_position = 10.0
		target_direction = 1.0
	
	#random direction
	if randf() < _delta *0.8:
		target_direction *= -1.0

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
	elif progress >= 100.0:
		_finished(true)

func _start_minigame() ->void:
	target_position = randf_range(30.0,70.0)
	target_direction = 1.0 if randf() > 0.5 else -1.0

	tension = 0.0
	progress = 0.0
	accuracy_sum = 0.0
	accuracy_samples = 0

	is_reel_button_pressed =false
	is_running = true
	finished = false

	balance_slider.set_value_no_signal(50.0)
	tension_bar.set_value_no_signal(0)
	catch_progress.set_value_no_signal(0)

	status_label.text = "Fish catched, hold the balance"
	reel_button.disabled = false


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
	reel_button.disabled = true

	# genauigkeit
	var _accuracy: float = 0.0

	if accuracy_samples > 0:
		_accuracy = accuracy_sum / float(accuracy_samples)

	if _result:
		status_label.text ="Catched."
	else:
		status_label.text = "The Fish has escaped."

	minigame_finished.emit(_result, _accuracy)