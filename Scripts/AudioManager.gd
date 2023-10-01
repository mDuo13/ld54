extends Node

func _ready():
	$BGMSupplement1.volume_db = -80
	$MainBGM.play()
	$BGMSupplement1.play()


func _on_plate_score_bonus(special_name, _special_deets):
	print("scored bonus:", special_name)
	$BGMSupplement1.volume_db = 0 # TODO: fade in gradually
