extends CanvasLayer

var score : int = 0

func _on_plate_score_piece(add_score):
	score += add_score
	$Score.text = "Score: %d" % score


func _on_done_butt_pressed():
	#get_tree().reload_current_scene() # TODO: actually code a score screen
	AudioManager.end_game()
	get_node("../Black").do_fade_then(to_score)

func to_score():
	get_tree().change_scene_to_file("res://scenes/score_screen.tscn")


func _on_plate_placed_piece():
	$PassButt.disabled = false



func _on_spin_ccw_pressed():
	var pcs = get_tree().get_nodes_in_group("Unplaced Pieces")
	for pc in pcs:
		pc.rotate_ccw()
