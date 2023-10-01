extends CanvasLayer

func _on_start_butt_pressed():
	get_tree().change_scene_to_file("res://scenes/play.tscn")



func _on_quit_butt_pressed():
	get_tree().quit()
