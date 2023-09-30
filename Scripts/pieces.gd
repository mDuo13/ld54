extends GridContainer

var pieces = {
	"2" : {
		"cells" : [
			1, 1
		],
		"type" : "basic"
	},
	"3" : {
		"cells" : [
			1, 1, 0, 0,
			1, 0, 0, 0
		],
		"type" : "basic"
	},
	"L" : {
		"cells" : [
			1, 1, 1, 0,
			1, 0, 0, 0
		],
		"type" : "advanced"
	},
	"J" : {
		"cells" : [
			1, 1, 1, 0,
			0, 0, 1, 0
		],
		"type" : "advanced"
	},
	"T" : {
		"cells" : [
			1, 1, 1, 0,
			0, 1, 0, 0
		],
		"type" : "advanced"
	},
	"S" : {
		"cells" : [
			0, 1, 1, 0,
			1, 1, 0, 0
		],
		"type" : "advanced"
	},
	"Z" : {
		"cells" : [
			1, 1, 0, 0,
			0, 1, 1, 0
		],
		"type" : "advanced"
	},
	"I" : {
		"cells" : [
			1, 1, 1, 1,
			0, 0, 0, 0
		],
		"type" : "advanced"
	},
	"O" : {
		"cells" : [
			1, 1, 0, 0,
			1, 1, 0, 0
		],
		"type" : "advanced"
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var piece = pieces[pieces.keys()[randi() % pieces.size()]]

	for type in piece["cells"]:
		print("running")
		var block = TextureRect.new()
		block.texture = load("res://Assets/Active.png")
		if type == 0:
			block.modulate.a = 0
		add_child(block)
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
