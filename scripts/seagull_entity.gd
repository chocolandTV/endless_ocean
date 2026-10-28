extends Node2D
class_name Seagull_Entity
@warning_ignore("unused_signal")
signal seagull_despawned(_id : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
func start_seagull()->void:
	if !multiplayer.is_server():
		return
	#print("Start Seagull childs")
	for x in get_children():
		if x is Seagull_Anim:
			x.start_seagull()