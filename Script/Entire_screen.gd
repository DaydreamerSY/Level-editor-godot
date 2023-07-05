extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_close_pressed():
	get_node("Help_panel").visible = false
	pass # Replace with function body.


func _on_btn_help_pressed():
	get_node("Help_panel").visible = true
	pass # Replace with function body.

