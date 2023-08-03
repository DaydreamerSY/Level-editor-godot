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
	
	for i in scroll_view.get_children():
		i.queue_free()
		
	var _checking_label = Label.new()
	_checking_label.text = "%s" % "Cheking, please wait..."
	_checking_label.size = Vector2(1100, 50)
	_checking_label.set("theme_override_fonts/font", load("res://GAME ASSETS/v.0.1/Action Phase/MilkyNice.ttf"))
	_checking_label.set("theme_override_font_sizes/font_size", 40)
	_checking_label.set("theme_override_colors/font_color", Color.html("#741e19"))
	scroll_view.add_child(_checking_label)
	
	await get_tree().create_timer(1.0).timeout
	
	if not button_pressed:
		return
	
	for i in scroll_view.get_children():
		i.queue_free()
	
	var output = []
	OS.execute("git", ["fetch"])
	OS.execute("git", ["log", "--invert-grep", "--grep=\"test\"", "--grep=\"Merge\"", "--pretty=format:%D  %ad  %s", "--date=short"], output)
#	print(params.split(" "))
#	OS.execute(base_app, params.split(" "), output)
	
	var log = output[0].split("\n")

	var _temp = ""
	var _output_line = []

	var is_tag = false
	
	for i in log:
		var message = ""
		
		if "tag" in i:
			is_tag = true
		else:
			is_tag = false
			message += "          |- "
		
		message += i
		message = message.replace("HEAD -> main, ", "")
		message = message.replace(", origin/main, origin/HEAD", "")
		message = message.replace(" origin/main, origin/HEAD", "")
		message = message.replace("tag:", "Ver:")
			
		
		
#		print(message)
			
		var _label = Label.new()
		_label.text = "%s" % message
		_label.size = Vector2(1100, 50)
		_label.set("theme_override_fonts/font", load("res://GAME ASSETS/v.0.1/Action Phase/MilkyNice.ttf"))
		_label.set("theme_override_font_sizes/font_size", 40)
		
		if is_tag:
			_label.set("theme_override_colors/font_color", Color.html("#741e19"))
		else:
			_label.set("theme_override_colors/font_color", Color.html("#a1716f"))
		
		scroll_view.add_child(_label)
			
	pass # Replace with function body.


func _on_btn_version_close_pressed():
	self.visible = false
	$"../../Fixed_buttons/btn_version".set ("button_pressed", false)
	pass # Replace with function body.
