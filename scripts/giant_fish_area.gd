extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(_area :Area2D) ->void:
	if _area is Fishing_net_area:
		if multiplayer.is_server():
			Network.request_boss_damage_from_server(_area.get_multiplayer_authority())
		else:
			Network.request_boss_damage.rpc_id(1)