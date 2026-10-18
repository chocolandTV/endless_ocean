extends Node2D
class_name Giant_Fish

@export var particle_scene : PackedScene =null

func _ready() -> void:
    Network.boss_finished.connect(_on_boss_finished)

func _on_boss_finished() ->void:
    print("boss finished, start baby spawn")
    if particle_scene != null:
        var particle_effect := particle_scene.instantiate() as Node2D
        if particle_effect == null:
            SoundManager.play_sfx("Error_Sound")
            push_error("Boss particle scene must have a Node2D root.")
        else:
            get_parent().add_child(particle_effect)
            particle_effect.global_position = global_position
    queue_free()