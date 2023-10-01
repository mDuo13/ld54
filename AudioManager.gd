extends Node

func _ready():
	$BGMSupplement1.volume_db = -80
	$MainBGM.play()
	$BGMSupplement1.play()


func _on_plate_score_bonus(score):
	print("scored bonus:", score)
	$BGMSupplement1.volume_db = 0 # TODO: fade in gradually
