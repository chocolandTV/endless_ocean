extends CharacterBody2D

const SPEED : float  = 500.0
@onready var sprite : Sprite2D =$Sprite2D

# set player node id to given multiplayer connector
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(_delta: float) -> void:
	# only move the correct characterbody2d with your multiplayer id
	if !is_multiplayer_authority():
		return
	var _direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity =  _direction * SPEED

	move_and_slide()
