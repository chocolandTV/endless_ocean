extends Panel
# array of all fish types 0 : default 1-10 rare, 11 koi baby
@export var fish_scenes : PackedScene

#show maximal 100 fishies
const MAX_FISH_COUNT : int = 100
# max fish crowd size 320 pixel
const CROWD_RADIUS : float = 160.0
# maximum distance a fish can drift from its spawn point
const MAX_SWIM_DISTANCE : float = 8.0
#eye of ezbhan -sunflower growth - angle in radians
const GOLDEN_ANGLE : float = 2.399963229728653

# base function spawn x fishe of type
func spawn_fishcrowd(_count : int, _type : int) ->void:
	for child in get_children():
		child.queue_free()
	if _type == null:
		_type = 0
	#clamp _count variable and secure if not 0
	var fish_count : int= clampi(_count, 0, MAX_FISH_COUNT)
	if fish_count == 0:
		return
	#scene is empty return
	if fish_scenes.is_empty():
		push_error("No fish scenes are configured")
		return

	#select scene and check if not null
	var fish_scene := fish_scenes
	if fish_scene == null:
		push_error("Fish scene is not configured.")
		return
	# for loop x to max count
	for index in fish_count:
		var fish_node := fish_scene.instantiate()
		var fish := fish_node as TextureRect
		if fish == null:
			fish_node.free()
			push_error("Fish scene for TextureRect root.")
			return
		if not fish.has_method("start_swimming"):
			fish_node.free()
			push_error("Fish scene must have the fish movement script." )
			return

		add_child(fish)
		# magic algorythm
		var radial_fraction :float = sqrt((float(index) + 0.5) / float(fish_count))
		var angle :float = float(index) * GOLDEN_ANGLE
		var fish_center :Vector2 = Vector2(cos(angle), sin(angle)) * CROWD_RADIUS * radial_fraction

		fish.position = fish_center - fish.size / 2.0
		var available_swim_distance := CROWD_RADIUS - fish_center.length()
		fish.call(
			"start_swimming",
			fish.position,
			minf(MAX_SWIM_DISTANCE, available_swim_distance),
			angle,
			randf_range(0.8, 1.2),
			_type
		)
