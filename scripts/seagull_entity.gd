extends Node2D
class_name Seagull_Entity


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
func start_seagull(_start_pos : Vector2, _target_pos: Vector2)->void:
	print("Start Seagull childs")
	for x in get_children():
		if x is Seagull_Anim:
			x.start_seagull(_start_pos, _target_pos)