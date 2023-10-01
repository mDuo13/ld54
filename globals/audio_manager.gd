extends Node

@onready var SPECIAL_TRACKS = {
	"special_1": $BGMSupplement1,
	"special_2": $BGMSupplement1,
	"special_3": $BGMSupplement1
}

var active_tweens = []

func start_game():
	$MainBGM.play()
	for bgm_n in SPECIAL_TRACKS:
		var bgm = SPECIAL_TRACKS[bgm_n]
		bgm.volume_db = -80
		bgm.play()

func end_game():
	$MainBGM.stop()
	for tween in active_tweens:
		tween.kill()
	for bgm_n in SPECIAL_TRACKS:
		SPECIAL_TRACKS[bgm_n].stop()

func add_bonus_track(special_name) -> void:
	#print("scored bonus:", special_name)
	if special_name not in SPECIAL_TRACKS.keys():
		print("No addtl music track for special", special_name)
		return
	var track = SPECIAL_TRACKS[special_name]
	var tween = get_tree().create_tween()
	tween.tween_property(track, "volume_db", 0, 2)
	active_tweens.append(tween)
