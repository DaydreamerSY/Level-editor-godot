extends TextureRect

var letter
var id

signal you_are_hover_on(id)
signal you_are_exit(id)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.connect("mouse_entered", _on_Area2D_mouse_entered)
	self.connect("mouse_exited", _on_Area2D_mouse_exited)
	letter = get_node("Letter").text
	id = float(get_node("ID").text)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Area2D_mouse_entered():
	you_are_hover_on.emit(id)
	
func _on_Area2D_mouse_exited():
	you_are_exit.emit(id)
