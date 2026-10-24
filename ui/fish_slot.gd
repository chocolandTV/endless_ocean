extends PanelContainer

@onready var _fish_name_label : Label = $MarginContainer/VBoxContainer/Fish_Name
@onready var _fish_texture : TextureRect = $MarginContainer/VBoxContainer/Header/VBoxContainer/Fish_Texture
@onready var _fish_catched_label : Label  =$MarginContainer/VBoxContainer/Header/PanelContainer/MarginContainer/HBoxContainer/Description_and_Value2/Catched_Value
@onready var _fish_chance_label  : Label = $MarginContainer/VBoxContainer/Header/PanelContainer/MarginContainer/HBoxContainer/Description_and_Value2/Chance_Value
@onready var _fish_score_label : Label = $MarginContainer/VBoxContainer/Header/PanelContainer/MarginContainer/HBoxContainer/Description_and_Value2/Score_Value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_slot(_name : String = "", _texture : Texture2D = null, _fish_catched : String ="", _fish_chance : String="", _fish_score : String ="") ->void:
	_fish_name_label.text = _name
	_fish_texture.texture = _texture
	_fish_catched_label.text = _fish_catched
	_fish_chance_label.text = _fish_chance
	_fish_score_label.text = _fish_score
