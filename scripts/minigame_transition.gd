extends PanelContainer
class_name MinigameTransition

@onready var colorrect : ColorRect = $ColorRect
@onready var label : Label = $Label

const OVERLAY_FADE_IN_SECONDS : float = 0.22
const LABEL_POP_SECONDS : float = 0.28
const LABEL_SETTLE_SECONDS : float = 0.12
const MESSAGE_VISIBLE_UNTIL_SECONDS : float = 1.45
const LABEL_FADE_OUT_SECONDS : float = 0.25
const OVERLAY_FADE_OUT_SECONDS : float = 0.42

var _transition_tween : Tween

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	colorrect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	colorrect.modulate.a = 0.0
	label.modulate.a = 0.0
	label.scale = Vector2(0.72, 0.72)
	label.pivot_offset = label.size / 2.0
	visible = false

func on_minigame_transition_win(_message : String, _time : float) -> void:
	if _transition_tween and _transition_tween.is_running():
		_transition_tween.kill()

	label.text = _message
	colorrect.modulate.a = 0.0
	label.modulate.a = 0.0
	label.scale = Vector2(0.72, 0.72)
	label.pivot_offset = label.size / 2.0
	

	var message_hold_seconds : float = 1.0

	_transition_tween = create_tween()
	var overlay_fade_in : PropertyTweener = _transition_tween.tween_property(
		colorrect, "modulate:a", 0.86, OVERLAY_FADE_IN_SECONDS
	)
	overlay_fade_in.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_transition_tween.tween_property(label, "modulate:a", 1.0, LABEL_POP_SECONDS * 0.7)
	var label_pop : PropertyTweener = _transition_tween.parallel().tween_property(
		label, "scale", Vector2(1.12, 1.12), LABEL_POP_SECONDS
	)
	label_pop.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var label_settle : PropertyTweener = _transition_tween.tween_property(
		label, "scale", Vector2.ONE, LABEL_SETTLE_SECONDS
	)
	label_settle.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_transition_tween.tween_interval(message_hold_seconds)
	var label_fade_out : PropertyTweener = _transition_tween.tween_property(
		label, "modulate:a", 0.0, LABEL_FADE_OUT_SECONDS
	)
	label_fade_out.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var overlay_fade_out : PropertyTweener = _transition_tween.tween_property(
		colorrect, "modulate:a", 0.0, OVERLAY_FADE_OUT_SECONDS
	)
	overlay_fade_out.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_transition_tween.tween_callback(_hide_transition)

func _hide_transition() -> void:
	visible = false