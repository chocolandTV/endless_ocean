extends Node

@onready var _music_overworld: AudioStreamPlayer = $Music_Overworld
@onready var _music_menu: AudioStreamPlayer = $Music_Menu
# Fishing_Net
# Fishing_Net_Failed
# Click_Sound
# Fish_Capured
# Fish_Escaped
# Error_Sound
# Plays an AudioStreamPlayer child by its exact node name, e.g. "Click_Sound".
func play_sfx(sound_name: String) -> void:
    var sound_player := get_node_or_null(sound_name) as AudioStreamPlayer
    if sound_player == null:
        push_warning("SoundManager: No AudioStreamPlayer named '%s'." % sound_name)
        return
    if sound_player.stream == null:
        push_warning("SoundManager: '%s' has no audio stream assigned." % sound_name)
        return

    sound_player.play()

func start_menu_music() -> void:
    if _music_overworld.playing:
        _music_overworld.stop()
    if not _music_menu.playing:
        _music_menu.play()

func start_overworld_music() ->void:
    if _music_menu.playing:
        _music_menu.stop()
    if not _music_overworld.playing:
        _music_overworld.play()