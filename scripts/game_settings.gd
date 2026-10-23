extends Node

var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.8
var show_name_tags: bool = true

# base core settings
var is_game_server : bool  = false
var is_game_save_data_local : bool = true

const ship_names: Array[String] = [
	"Sweet Caroline",
	"Flying Marry",
	"Flying Lamp",
	"Thousand Sunny",
	"King of Red Lions",
	"Santa Maria",
	"Mayflower",
	"Endeavour",
	"HMS Beagle",
	"Golden Hind",
	"HMS Victory",
	"USS Constitution",
	"Vasa",
	"Mary Celeste",
	"Cutty Sark",
	"HMS Pickle",
]

func _ready() -> void:
	_apply_bus_volume("Master", master_volume)
	_apply_bus_volume("Music", music_volume)
	_apply_bus_volume("SFX", sfx_volume)

func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_apply_bus_volume("Master", master_volume)

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_apply_bus_volume("Music", music_volume)

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_apply_bus_volume("SFX", sfx_volume)

func set_name_tags_enabled(enabled: bool) -> void:
	show_name_tags = enabled

func _apply_bus_volume(bus_name: String, linear_volume: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index == -1:
		push_warning("GameSettings: Audio bus '%s' does not exist." % bus_name)
		return

	AudioServer.set_bus_mute(bus_index, is_zero_approx(linear_volume))
	AudioServer.set_bus_volume_db(
		bus_index,
		linear_to_db(maxf(linear_volume, 0.0001))
	)