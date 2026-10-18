extends Control

const GAME_SCENE_PATH: String = "res://scenes/game_scene.tscn"
const BACKGROUND_TEXTURE: Texture2D = preload("res://assets/textures/background_ocean.png")
const WAVES_TEXTURE: Texture2D = preload("res://assets/textures/background_ocean_waves.png")
const SCROLLING_OVERLAY_SHADER: Shader = preload("res://shaders/menu_scrolling_overlay.gdshader")

const COLOR_BACKGROUND := Color("#0d181a1a")
const COLOR_PANEL := Color("#0d181a", 0.92)
const COLOR_ACCENT := Color("#69cee0")
const COLOR_TEXT := Color("#69cee0")
const COLOR_MUTED := Color("#4a8a95")
const COLOR_BUTTON := Color("#315e66")
const COLOR_BUTTON_HOVER := Color("#4a8a95")
const COLOR_WARM := Color("#663931")
const COLOR_WARM_HOVER := Color("#ab6457")
const COLOR_WARM_ACCENT := Color("#ed8572")

var _content: VBoxContainer

func _ready() -> void:
	_build_menu()
	SoundManager.start_menu_music()

func _start_game() -> void:
	SoundManager.play_sfx("Click_Sound")
	var error := get_tree().change_scene_to_file(GAME_SCENE_PATH)
	if error != OK:
		SoundManager.play_sfx("Error_Sound")
		push_error("Unable to open the game scene: %s" % GAME_SCENE_PATH)

func _quit_game() -> void:
	SoundManager.play_sfx("Click_Sound")
	get_tree().quit()

############################ MENU 
func _build_menu() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	# old
	#var background := TextureRect.new()
	#background.texture = BACKGROUND_TEXTURE
	#background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	#background.stretch_mode = TextureRect.STRETCH_SCALE
	#background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	#add_child(background)
	# fh
	var tint := ColorRect.new()
	tint.color = COLOR_BACKGROUND
	tint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	tint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(tint)

	var waves_overlay := TextureRect.new()
	waves_overlay.texture = WAVES_TEXTURE
	waves_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	waves_overlay.stretch_mode = TextureRect.STRETCH_SCALE
	waves_overlay.modulate = Color(COLOR_ACCENT, 0.28)
	waves_overlay.material = ShaderMaterial.new()
	waves_overlay.material.shader = SCROLLING_OVERLAY_SHADER
	waves_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	waves_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(waves_overlay)

	var page_margin := MarginContainer.new()
	page_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	page_margin.add_theme_constant_override("margin_left", 72)
	page_margin.add_theme_constant_override("margin_top", 52)
	page_margin.add_theme_constant_override("margin_right", 72)
	page_margin.add_theme_constant_override("margin_bottom", 52)
	add_child(page_margin)

	var layout := HBoxContainer.new()
	layout.add_theme_constant_override("separation", 48)
	page_margin.add_child(layout)

	var navigation := VBoxContainer.new()
	navigation.custom_minimum_size.x = 310
	navigation.add_theme_constant_override("separation", 13)
	navigation.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	layout.add_child(navigation)

	var eyebrow := _make_label("A LITTLE ADVENTURE ABOUT THE OCEAN", 14, COLOR_ACCENT)
	navigation.add_child(eyebrow)
	var title := _make_label("ENDLESS\nOCEAN", 58, COLOR_TEXT)
	title.add_theme_constant_override("line_spacing", -8)
	navigation.add_child(title)
	var tagline := _make_label("endless exploration. find your own tide.", 17, COLOR_MUTED)
	tagline.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	navigation.add_child(tagline)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 28
	navigation.add_child(spacer)

	_add_menu_button(navigation, "Start Game", _start_game, true)
	_add_menu_button(navigation, "Settings", _show_settings)
	_add_menu_button(navigation, "Credits", _show_credits)
	_add_menu_button(navigation, "Quit", _quit_game)

	var footer := _make_label("made for Godot Wild Jam #98", 12, COLOR_MUTED)
	footer.add_theme_constant_override("outline_size", 2)
	navigation.add_child(footer)

	var content_panel := PanelContainer.new()
	content_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_panel.add_theme_stylebox_override("panel", _panel_style(COLOR_PANEL, 24))
	layout.add_child(content_panel)

	var content_margin := MarginContainer.new()
	content_margin.add_theme_constant_override("margin_left", 38)
	content_margin.add_theme_constant_override("margin_top", 34)
	content_margin.add_theme_constant_override("margin_right", 38)
	content_margin.add_theme_constant_override("margin_bottom", 34)
	content_panel.add_child(content_margin)

	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 20)
	content_margin.add_child(_content)
	_show_welcome()

func _add_menu_button(parent: VBoxContainer, text: String, callback: Callable, is_primary: bool = false) -> void:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 56)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", COLOR_TEXT)
	if is_primary:
		button.add_theme_stylebox_override("normal", _panel_style(COLOR_BUTTON, 12))
		button.add_theme_stylebox_override("hover", _panel_style(COLOR_BUTTON_HOVER, 12))
	else:
		button.add_theme_stylebox_override("normal", _panel_style(Color(COLOR_BUTTON, 0.65), 12))
		button.add_theme_stylebox_override("hover", _panel_style(COLOR_WARM, 12))
	button.add_theme_stylebox_override("pressed", _panel_style(COLOR_WARM_HOVER, 12))
	button.pressed.connect(callback)
	parent.add_child(button)

func _show_welcome() -> void:
	_clear_content()
	_add_section_heading("Ja Moin", "calls at germany coast, feel free to take a ride with an epic boat across the ocean.")
	var info := _make_label(
		"Controls\n\n"
		+ "Use W and S to Accelerate or Brake, use A and D to rotate your ship. Press Space to fish when the sonar finds a nearby catch.",
		18,
		COLOR_MUTED
	)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(info)

######################### SETTINGS
func _show_settings() -> void:
	SoundManager.play_sfx("Click_Sound")
	_clear_content()
	_add_section_heading("SETTINGS", "Ocean feels right")
	_add_volume_slider("Master Volume", GameSettings.master_volume, GameSettings.set_master_volume)
	_add_volume_slider("Music", GameSettings.music_volume, GameSettings.set_music_volume)
	_add_volume_slider("Sound Effects", GameSettings.sfx_volume, GameSettings.set_sfx_volume)

	var name_tags := CheckButton.new()
	name_tags.text = "Show player name tags"
	name_tags.button_pressed = GameSettings.show_name_tags
	name_tags.add_theme_font_size_override("font_size", 17)
	name_tags.add_theme_color_override("font_color", COLOR_TEXT)
	name_tags.toggled.connect(GameSettings.set_name_tags_enabled)
	_content.add_child(name_tags)

func _add_volume_slider(
	title: String,
	initial_value: float,
	on_value_changed: Callable
) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 7)
	_content.add_child(row)

	var heading_row := HBoxContainer.new()
	row.add_child(heading_row)
	var title_label := _make_label(title, 17, COLOR_TEXT)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_row.add_child(title_label)

	var value_label := _make_label("%d%%" % roundi(initial_value * 100.0), 15, COLOR_ACCENT)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	heading_row.add_child(value_label)

	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.value = initial_value
	slider.custom_minimum_size.y = 24
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(func(value: float) -> void:
		on_value_changed.call(value)
		value_label.text = "%d%%" % roundi(value * 100.0)
	)
	row.add_child(slider)
# Credit TAB
func _show_credits() -> void:
	SoundManager.play_sfx("Click_Sound")
	_clear_content()
	_add_section_heading("CREDITS", "This is my first multiplayer game, i hope you enjoy it.")
	_add_credit_line("CREATED BY", "Robert Mögenburg")
	_add_credit_line("ENGINE", "Godot Engine %s" % Engine.get_version_info().get("string", ""))
	_add_credit_line("PROGRAMS", "Krita, Vscode, Firefox, Audacity, Filezilla, Terminal")
	var additional_infos := _make_label("How did this game fit the theme: the main mechanic of the game Fishing need a signal of a fish.\n And the game has multiplayer with over 26 Signals to enjoy the experience.", 15, COLOR_MUTED)
	_content.add_child(additional_infos)
# build credit
func _add_credit_line(heading: String, value: String) -> void:
	var group := VBoxContainer.new()
	group.add_theme_constant_override("separation", 5)
	_content.add_child(group)
	group.add_child(_make_label(heading, 12, COLOR_ACCENT))
	var detail := _make_label(value, 18, COLOR_TEXT)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	group.add_child(detail)

func _add_section_heading(title: String, subtitle: String) -> void:
	_content.add_child(_make_label(title, 30, COLOR_TEXT))
	var detail := _make_label(subtitle, 16, COLOR_MUTED)
	detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(detail)

func _clear_content() -> void:
	for child in _content.get_children():
		child.queue_free()

func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _panel_style(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 18.0
	style.content_margin_top = 12.0
	style.content_margin_right = 18.0
	style.content_margin_bottom = 12.0
	style.border_color = Color(COLOR_WARM_ACCENT, 0.35)
	style.set_border_width_all(1)
	return style
