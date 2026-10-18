extends PointLight2D



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("spot_light"):
		enabled = !enabled
		#click sound
