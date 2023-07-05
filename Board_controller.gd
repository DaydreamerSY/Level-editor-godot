extends Node



# Called when the node enters the scene tree for the first time.
func _ready():
	var data = _load("chapter0")
	print(data)
	pass




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _load(file_name):
	var path = "user://" + file_name + ".json"
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	return content

