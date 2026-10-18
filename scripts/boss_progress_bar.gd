extends ProgressBar

@export var sprite: Sprite2D

const HEALTH_TWEEN_SECONDS: float = 0.28
const HIT_TWEEN_SECONDS: float = 0.24
const HIT_SKEW: float = 0.06

var current_health: float = 100.0
var _has_received_health: bool = false
var _health_tween: Tween
var _sprite_hit_tween: Tween
var _sprite_resting_scale: Vector2
var _sprite_resting_rotation: float
var _sprite_resting_skew: float

func _ready() -> void:
	if sprite:
		_sprite_resting_scale = sprite.scale
		_sprite_resting_rotation = sprite.rotation
		_sprite_resting_skew = sprite.skew
	Network.game_state_updated.connect(_on_game_state_updated)

func _on_game_state_updated(_state: Dictionary) -> void:
	if _state.has("boss_health"):
		var new_health: float = float(_state["boss_health"])
		if not _has_received_health:
			_has_received_health = true
			current_health = new_health
			set_value_no_signal(new_health)
			return

		if is_equal_approx(new_health, current_health):
			return

		var took_damage: bool = new_health < current_health
		current_health = new_health
		_animate_health_change(new_health, took_damage)

func _animate_health_change(new_health: float, took_damage: bool) -> void:
	if _health_tween and _health_tween.is_running():
		_health_tween.kill()

	_health_tween = create_tween()
	_health_tween.tween_property(self, "value", new_health, HEALTH_TWEEN_SECONDS)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	if took_damage:
		_play_hit_effect()

func _play_hit_effect() -> void:
	if not is_instance_valid(sprite):
		return

	if _sprite_hit_tween and _sprite_hit_tween.is_running():
		_sprite_hit_tween.kill()

	sprite.scale = _sprite_resting_scale
	sprite.rotation = _sprite_resting_rotation
	sprite.skew = _sprite_resting_skew

	_sprite_hit_tween = create_tween()
	_sprite_hit_tween.tween_property(
		sprite,
		"scale",
		_sprite_resting_scale * Vector2(1.06, 0.94),
		0.07
	).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_sprite_hit_tween.parallel().tween_property(
		sprite,
		"rotation",
		_sprite_resting_rotation - 0.055,
		0.07
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_sprite_hit_tween.parallel().tween_property(
		sprite,
		"skew",
		_sprite_resting_skew + HIT_SKEW,
		0.07
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	_sprite_hit_tween.tween_property(sprite, "scale", _sprite_resting_scale, HIT_TWEEN_SECONDS)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	_sprite_hit_tween.parallel().tween_property(sprite, "rotation", _sprite_resting_rotation, HIT_TWEEN_SECONDS)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_sprite_hit_tween.parallel().tween_property(sprite, "skew", _sprite_resting_skew, HIT_TWEEN_SECONDS)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
