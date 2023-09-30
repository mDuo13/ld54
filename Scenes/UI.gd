extends CanvasLayer

var score : int = 0

func _on_plate_score_piece(add_score):
	score += add_score
	$Score.text = "Score: %d" % score


func _on_done_butt_pressed():
	get_tree().reload_current_scene() # TODO: actually code a score screen
