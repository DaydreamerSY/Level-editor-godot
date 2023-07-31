extends TextureButton

var bg_state_false
var bg_state_true
var icon

# Called when the node enters the scene tree for the first time.
func _ready():
	bg_state_false = $background_off
	bg_state_true = $background_on
	icon = $Icon
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_toggled(button_pressed):
	if button_pressed:
		bg_state_false.visible = false
		bg_state_true.visible = true
		icon.position.x += bg_state_false.size.x / 2
	else: 
		bg_state_false.visible = true
		bg_state_true.visible = false
		icon.position.x -= bg_state_false.size.x / 2
	pass # Replace with function body.
