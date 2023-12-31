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

var edit_mode
var test_mode
var view_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	
	wallpaper = $wallpaper
	livewallpaper_controller = $livewallpaper_controller

	setting_wallpaper_dropdown = $Setting_screen/Setting_screen/MarginContainer/Setting/Wallpaper/dropdown_wallpaper
	setting_livewallpaper_dropdown = $Setting_screen/Setting_screen/MarginContainer/Setting/Live_wallpaper/dropdown_livewallpaper

	edit_mode = $Edit_mode
	test_mode = $Playtest_mode
	view_mode = $Edit_chapter_mode

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
#	print(dir.get_files())
	
	setting_wallpaper_dropdown.add_item("Default")
	
	for img in dir.get_files():
		setting_wallpaper_dropdown.add_item(img)
		setting_change_wallpaper.append(PATH_BACKGROUND_IMG + img)
	pass


func _create_change_livewallpaper():
	var dir = DirAccess.open(PATH_BACKGROUND_OGV)
#	print(dir.get_files())
	
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
	var default_text = "Updating..."
	var label_warning = $"Popups-notif/Update_warning/chapter_select/MarginContainer/GridContainer/Warning"
	var popup_update_warning = $"Popups-notif/Update_warning"
	var popup_text = $"Popups-notif/Update_warning/chapter_select/MarginContainer/GridContainer/Warning"
	var popup_tip = $"Popups-notif/Update_warning/chapter_select/MarginContainer/GridContainer/Tip"
	

	$Edit_mode.visible = false
	$Playtest_mode.visible = false
	$Edit_chapter_mode.visible = false
	$Help_screen.visible = false
	$Setting_screen.visible = false
	$Fixed_buttons.visible = false
	
	popup_update_warning.visible = true
	popup_tip.visible = false

	
	popup_text.text = default_text
	await get_tree().create_timer(0.5).timeout
	
	var output = []
	OS.execute("git", ["fetch"], output)
	OS.execute("git", ["reset", "--hard", "origin"], output)
	
	popup_text.text = ""
	
	for i in output:
		if not i == "":
			label_warning.text += "- %s\n" % [i]

	popup_tip.visible = true
#	print(output)


func _on_check_box_edit_border_pressed():
	$Edit_mode/Edit_zone/Background_border.visible = !$Edit_mode/Edit_zone/Background_border.visible
	pass # Replace with function body.




func _on_view_mode_toggled(button_pressed):
	if button_pressed:
		view_mode.visible = true
		$"Popups-notif/Swap_warning".visible = true
		$Edit_chapter_mode/Chapter_view._load_chapter_view()
		
		edit_mode.visible = false
		test_mode.visible = false
	else:
		view_mode.visible = false
		edit_mode.visible = true
		test_mode.visible = false
	pass # Replace with function body.


func _on_playtest_mode_pressed():
	edit_mode.visible = false
	test_mode.visible = true
	
	$Playtest_mode/Control_zone/chapter_select/label_chapter/selected_chapter.text = $Edit_mode/Control_zone/chapter_select/label_chapter/selected_chapter.text
	$Playtest_mode/Control_zone/chapter_select/label_level/selected_level.text = $Edit_mode/Control_zone/chapter_select/label_level/selected_level.text
	$Playtest_mode/Edit_zone._on_btn_load_pressed()
	pass # Replace with function body.


func _on_edit_mode_pressed():
	edit_mode.visible = true
	test_mode.visible = false
	
	$Edit_mode/Control_zone/chapter_select/label_chapter/selected_chapter.text = $Playtest_mode/Control_zone/chapter_select/label_chapter/selected_chapter.text
	$Edit_mode/Control_zone/chapter_select/label_level/selected_level.text = $Playtest_mode/Control_zone/chapter_select/label_level/selected_level.text
	$Edit_mode/Edit_zone._on_btn_load_pressed()
	pass # Replace with function body.


func _on_btn_swap_close_pressed():
	$"Popups-notif/Swap_warning".visible = false
	pass # Replace with function body.

