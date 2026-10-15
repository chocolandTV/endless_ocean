extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_body_exited(body: Node2D) -> void:
	if body is Boat_Controller:
		body.set_collision_layer_value(1,true)
		print("body is exited")

func _on_body_entered(body: Node2D) -> void:
	if body is Boat_Controller:
		body.set_collision_layer_value(1,false)
		print("body is entered")