extends TextureRect

var letter
var id

signal you_are_hover_on(id)
signal you_are_exit(id)

var defaul_font_color 

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("mouse_entered", _on_Area2D_mouse_entered)
	self.connect("mouse_exited", _on_Area2D_mouse_exited)
	letter = get_node("Letter").text
	id = float(get_node("ID").text)
	defaul_font_color = get_node("Letter").get("theme_override_colors/font_color")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Area2D_mouse_entered():
#	self.texture = load("res://GAME ASSETS/v.0.1/Pop Up - Complete/button.png")
	self.texture = load("res://GAME ASSETS/Block_blue.png")
	get_node("Letter").set("theme_override_colors/font_color", Color.WHITE_SMOKE)
	you_are_hover_on.emit(id)
	
func _on_Area2D_mouse_exited():
	self.texture = load("res://GAME ASSETS/v.0.1/Calendar/paper_bottom.png")
	get_node("Letter").set("theme_override_colors/font_color", defaul_font_color)
	you_are_exit.emit(id)
