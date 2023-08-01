extends TextureButton

@export var bg_state_false : NinePatchRect
@export var bg_state_true : NinePatchRect
@export var icon : TextureRect

var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_toggled(button_pressed):
	
	tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	
	if button_pressed:
#		bg_state_false.visible = false
#		bg_state_true.visible = true
#		icon.position.x += bg_state_false.size.x / 2
		
		tween.tween_property(
			icon,
			"position:x",
			icon.position.x + bg_state_false.size.x / 2,
			0.3
		)
		tween.tween_callback(bg_state_false.set.bind("visible", false))
		tween.tween_callback(bg_state_true.set.bind("visible", true))
		
	else: 
#		bg_state_false.visible = true
#		bg_state_true.visible = false
#		icon.position.x -= bg_state_false.size.x / 2
		
		tween.tween_property(
			icon,
			"position:x",
			icon.position.x - bg_state_false.size.x / 2,
			0.3
		)
		tween.tween_callback(bg_state_false.set.bind("visible", true))
		tween.tween_callback(bg_state_true.set.bind("visible", false))
	pass # Replace with function body.
