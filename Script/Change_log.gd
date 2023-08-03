extends Control

var scroll_view
var label_warning

# Called when the node enters the scene tree for the first time.
func _ready():
	
	scroll_view = $chapter_select/MarginContainer/ScrollContainer/VBoxContainer
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_btn_version_toggled(button_pressed):
	
	self.visible = button_pressed
	
	if not button_pressed:
		return
	
	for i in scroll_view.get_children():
		i.queue_free()
	
	var output = []
	OS.execute("git", ["log", "-5"], output)
	
	var log = output[0].split("\n")

	var counter = 0
	var _temp = ""
	var _output_line = []
	for i in range(len(log)):
		if counter >= 5:
			print(_temp)
			_output_line.append(_temp)
			_temp = ""
			counter = 0
		else:
			_temp += log[i]
			counter += 1

	for i in _output_line:
		if not i == "":
			var _label = Label.new()
			_label.text = "- %s" % [i]
			_label.size = Vector2(1100, 50)
			_label.set("theme_override_fonts/font", load("res://GAME ASSETS/v.0.1/Action Phase/MilkyNice.ttf"))
			_label.set("theme_override_font_sizes/font_size", 40)
			scroll_view.add_child(_label)
			
	print("done")
	pass # Replace with function body.
