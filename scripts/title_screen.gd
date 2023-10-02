extends CanvasLayer

func _ready():
	AudioManager.play_title_music()

func _on_start_butt_pressed():
	AudioManager.stop_title_music()
	$Black.fade_to_scene("res://scenes/play.tscn")


func _on_quit_butt_pressed():
	get_tree().quit()


func _on_how_to_butt_pressed():
	$Black.fade_to_scene("res://scenes/tutorial.tscn")

