extends ColorRect
# Dunno why this doesn't work for doing fade transitions if put in Autoload

func _ready():
	visible = true
	# fade in
	var tween = get_tree().create_tween()
	tween.tween_property(self, "color", Color(0.0,0.0,0.0,0.0), 0.35)

func do_fade_then(callback):
	var tween = get_tree().create_tween()
	tween.tween_property(self, "color", Color(0.0,0.0,0.0,1.0), 0.35)
	tween.tween_callback(callback)


func fade_to_scene(scene: String):
	var transition = get_tree().change_scene_to_file.bind(scene)
	do_fade_then(transition)
