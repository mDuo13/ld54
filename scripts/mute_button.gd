extends Button

var audible : bool

func _ready():
	audible = AudioManager.is_audible()
	set_mute_text_status()

func set_mute_text_status():
	if audible:
		text = "🔊"
	else:
		text = "🔇"

func _on_pressed():
	audible = not audible
	set_mute_text_status()
	AudioManager.toggle_master(audible)
