extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/VBoxContainer2/Symbols.text = string_score(ScoreSaver.symbols_scored)
	$HBoxContainer/VBoxContainer2/Specials.text = string_score(ScoreSaver.specials_scored)
	$HBoxContainer/VBoxContainer2/Specials2.text = string_score(ScoreSaver.points_from_specials, 45)
	$HBoxContainer/VBoxContainer2/Sweets.text = string_score(ScoreSaver.sweets_scored, 45)
	$HBoxContainer/VBoxContainer2/Savory.text = string_score(ScoreSaver.savory_scored, 45)
	$HBoxContainer/VBoxContainer2/TurnsTaken.text = string_score(ScoreSaver.turns)
	$HBoxContainer/VBoxContainer2/TotalScore.text = string_score(ScoreSaver.total_score, 20)
	
func string_score(i: int, pad_amount=35) -> String:
	var s = "%*d" % [pad_amount, i]
	
	return s.replace(" ",".")


func _on_order_again_pressed():
	get_tree().change_scene_to_file("res://scenes/play.tscn")


func _on_to_title_pressed():
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
