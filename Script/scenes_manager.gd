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

var wallpaper
var livewallpaper_controller

var setting_wallpaper_dropdown
var setting_change_wallpaper = ["res://GAME ASSETS/beach.jpg"]

var setting_livewallpaper_dropdown
var setting_change_livewallpaper = ["None", "res://GAME ASSETS/starlight.ogv"]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	wallpaper = $wallpaper
	livewallpaper_controller = $livewallpaper_controller

	setting_wallpaper_dropdown = $Setting_screen/Setting_screen/MarginContainer/Setting/dropdown_wallpaper
	setting_livewallpaper_dropdown = $Setting_screen/Setting_screen/MarginContainer/Setting/dropdown_livewallpaper

	var dir_creater = DirAccess.open("user://")
	var dir_checker = null
	
	for dir in list_of_dir:
		dir_checker = DirAccess.open(dir)
		if dir_checker == null:
			dir_creater.make_dir_recursive(dir)
	
	_create_change_wallpaper()
	_create_change_livewallpaper()
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


func _create_change_livewallpaper():
	var dir = DirAccess.open(PATH_BACKGROUND_OGV)
	print(dir.get_files())
	
	setting_livewallpaper_dropdown.add_item("None")
	setting_livewallpaper_dropdown.add_item("Default")
	
	for ogv in dir.get_files():
		setting_livewallpaper_dropdown.add_item(ogv)
		setting_change_livewallpaper.append(PATH_BACKGROUND_OGV + ogv)
	pass

func _on_dropdown_wallpaper_item_selected(index):
	var img_path = setting_change_wallpaper[index]
	var image = Image.new()
	image.load(img_path)

	var image_texture = ImageTexture.new()
	image_texture.set_image(image)
	
	wallpaper.set("texture", image_texture)
	


func _on_dropdown_livewallpaper_item_selected(index):
	if index == 0:
		livewallpaper_controller.visible = false
	else:
		livewallpaper_controller.visible = true
	livewallpaper_controller._load_ogv(setting_change_livewallpaper[index])




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


func _on_check_box_flip_h_pressed():
	wallpaper.set("flip_h", !wallpaper.get("flip_h"))
	pass # Replace with function body.


func _on_check_box_flip_h_2_pressed():
	wallpaper.set("flip_v", !wallpaper.get("flip_v"))
	pass # Replace with function body.


func _on_update_pressed():
	var output = []
	OS.execute("git", ["fetch"], output)
	OS.execute("git", ["reset", "--hard", "origin"], output)
	print(output)


func _on_check_box_edit_border_pressed():
	$Edit_mode/Edit_zone/Background_border.visible = !$Edit_mode/Edit_zone/Background_border.visible
	pass # Replace with function body.
