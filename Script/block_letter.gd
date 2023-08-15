extends TextureRect

var letter
var id
var self_is_active = false

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

func _set_active(is_active, type=1):
	self_is_active = is_active
	if is_active:
		match type:
			1:
				self.texture = load("res://GAME ASSETS/v.0.2 new/Block_blue.png")
			2:
				self.texture = load("res://GAME ASSETS/v.0.1/Action Phase/Block_passive.png")
#		self.set("size", Vector2(60, 60))
	else:
		self.texture = load("res://GAME ASSETS/v.0.1/Action Phase/Block-type-active/Block_active_board.png")
#		self.set("size", Vector2(50, 50))
	pass

func _is_active():
	return self_is_active
