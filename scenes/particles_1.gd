extends GPUParticles2D

const COLOR_BASIC = Color("#42bbff")
const COLOR_ADVANCED = Color("#9c7751")#slightly darker/more visible than their main, Color("#ffcb3e")
const COLOR_RAINBOW = preload("res://assets/rainbow.tres")

@onready var countdown = lifetime
func _ready():
	emitting = true # for some reason the editor keeps turning this off

func _process(delta):
	if not self.emitting:
		if lifetime < delta:
			queue_free()
		else:
			lifetime -= delta

func set_type(t: String) -> void:
	if t == "basic":
		process_material.color = COLOR_BASIC
		amount = 50
	elif t == "advanced":
		process_material.color = COLOR_ADVANCED
		amount = 150
	elif t == "special":
		process_material.color_initial_ramp = COLOR_RAINBOW
		amount = 150
		lifetime = 0.5
	else:
		print("unknown particle setting:", t)
