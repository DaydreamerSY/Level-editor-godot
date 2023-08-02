extends Control

var scroll_view
var label_warning

# Called when the node enters the scene tree for the first time.
func _ready():
	
	scroll_view = $chapter_select/MarginContainer/ScrollContainer/VBoxContainer
	
	var output = []
	OS.execute("git", ["log"], output)
	
	for i in output:
		if not i == "":
			var label = Label.new()
			label.text += "- %s" % [i]
			scroll_view.add_child(label)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
