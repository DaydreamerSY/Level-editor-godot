extends VBoxContainer

var label_level
var level_contain

# Called when the node enters the scene tree for the first time.
func _ready():
	label_level = $Level
	level_contain = $Level_content
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _set_level_name(name):
	label_level.text = str(name)
	
func _set_grid_col(n):
	level_contain.set("columns", n)
	
func _add_item(item):
	level_contain.add_child(item)
