extends Control

var PATH_FOLDER_CHAPTER = "user://Level Layout/"
var PATH_FOLDER_LEVEL_CONTENT = "user://Level Content/"
var PATH_BACKGROUND_IMG = "user://Background/Wallpaper/"
var PATH_BACKGROUND_OGV = "user://Background/LiveWallpaper/"

var list_of_dir = [
	PATH_FOLDER_CHAPTER,
	PATH_FOLDER_LEVEL_CONTENT,
	PATH_BACKGROUND_IMG,
	PATH_BACKGROUND_OGV
]

var setting_wallpaper_dropdown
var setting_change_wallpaper = ["res://GAME ASSETS/beach.jpg"]

#var setting_livewallpaper_dropdown
#var setting_change_livewallpaper = ["res://GAME ASSETS/beach.jpg"]

# Called when the node enters the scene tree for the first time.
func _ready():

	setting_wallpaper_dropdown = $Setting_screen/Setting_screen/MarginContainer/Setting/dropdown_wallpaper

	var dir_creater = DirAccess.open("user://")
	var dir_checker = null
	
	for dir in list_of_dir:
		dir_checker = DirAccess.open(dir)
		if dir_checker == null:
			dir_creater.make_dir_recursive(dir)
	
	_create_change_wallpaper()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _create_change_wallpaper():
	var dir = DirAccess.open(PATH_BACKGROUND_IMG)
	print(dir.get_files())
	
	setting_wallpaper_dropdown.add_item("Default")
	
	for img in dir.get_files():
		setting_wallpaper_dropdown.add_item(img)
		setting_change_wallpaper.append(PATH_BACKGROUND_IMG + img)
	pass


func _on_close_pressed():
	$Help_screen/Help_panel.visible = false
	pass # Re$Help_screen/Help_panelplace with function body.


func _on_btn_help_pressed():
	$Help_screen/Help_panel.visible = true
	pass # Replace with function body.


func _on_btn_setting_pressed():
	$Setting_screen/Setting_screen.visible = true
	pass # Replace with function body.


func _on_btn_setting_close_pressed():
	$Setting_screen/Setting_screen.visible = false
	pass # Replace with function body.



func _on_dropdown_wallpaper_item_selected(index):
	var img_path = setting_change_wallpaper[index]
	var image = Image.new()
	image.load(img_path)
	
	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	$Background.set("texture", image_texture)

	pass # Replace with function body.
	pass # Replace with function body.
