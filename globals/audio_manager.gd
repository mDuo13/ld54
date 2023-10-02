extends Node

@onready var SPECIAL_TRACKS = [
	$BGMSupplement1,
	$BGMSupplement2,
]
var specials_active = 0

var active_tweens = []
var audio_enabled = true

const OMNOMNOM = preload("res://assets/audio/omnomnom.ogg")
const DING_SM = preload("res://assets/audio/ding-sm.ogg")
const DING_MD = preload("res://assets/audio/ding-md.ogg")
const DING_LG = preload("res://assets/audio/ding-lg.ogg")

func start_game():
	$MainBGM.play()
	specials_active = 0
	for bgm in SPECIAL_TRACKS:
		bgm.volume_db = -80
		bgm.play()

func end_game():
	$MainBGM.stop()
	for tween in active_tweens:
		tween.kill()
	for bgm in SPECIAL_TRACKS:
		bgm.stop()

func add_bonus_track(special_name) -> void:
	#print("scored bonus:", special_name)
#	if special_name not in SPECIAL_TRACKS.keys():
#		print("No addtl music track for special", special_name)
#		return
	#var track = SPECIAL_TRACKS[special_name]
	if specials_active >= SPECIAL_TRACKS.size():
		print("no addt'l music for specials, already playing", specials_active, "tracks")
		return
	var track = SPECIAL_TRACKS[specials_active]
	specials_active += 1
	var tween = get_tree().create_tween()
	tween.tween_property(track, "volume_db", 0, 2)
	active_tweens.append(tween)

func play_title_music() -> void:
	if not $Ambient2.playing:
		var tween = get_tree().create_tween()
		tween.tween_property($Ambient2, "volume_db", -20, 1.0)
		$Ambient2.play()

func sfx(res):
	$SFXPlayer.stream = res
	$SFXPlayer.play()

func stop_title_music():
	var tween = get_tree().create_tween()
	tween.tween_property($Ambient2, "volume_db", -80, 1.0)
	tween.tween_callback($Ambient2.stop)

func toggle_master(on_off : bool) -> void:
	AudioServer.set_bus_mute(0, not on_off)

func is_audible() -> bool:
	return not AudioServer.is_bus_mute(0)
