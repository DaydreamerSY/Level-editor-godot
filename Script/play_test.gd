extends Control

@export var block_holder: PackedScene
@export var block_letter: PackedScene
@export var particle_booster: PackedScene


var COLOR_CODE = {
	"red": Color("#fa98a7"),
	"green": Color("#79d97b"),
	"yellow": Color.LIGHT_GOLDENROD
}

# default setting
var SETTING = {
	"showBackground": true, # Default: 35 false. if false, showBlockHolder false too (even it set to true)
	"showBlockHolder": true,
	"letterSize": {
		"background": Vector2(60, 60), # Default: Vector2(50, 50)
		"letter": 40 # Default: 35. Background increse 10 then letter increase 5 
	},
	"snapStep": 65, # Default: 55. snapStep = SETTING["letterSize"]["background"].x + 5
	"animationSpeed": 0.5,
	"playtestSize": {
		"background": Vector2(110, 110), # Default: Vector2(50, 50)
		"letter": 80 # Default: 35. Background increse 10 then letter increase 5 
	}
}

var START_POSITION = SETTING["letterSize"]["background"]

var LEVEL_EDIT_SIZE = 20
var SIZE = {"row": LEVEL_EDIT_SIZE, "col": LEVEL_EDIT_SIZE}
var PADDING = {"top": 5, "right": 5, "bottom": 0, "left": 0}

var BOARD_BG = []
var BOARD_FG = []

var PATH_FOLDER_CHAPTER = "user://Level Layout/"
var PATH_FOLDER_LEVEL_CONTENT = "user://Level Content/"

var PATH_CHAPTER = "user://Level Layout/chapter%d.json"
var PATH_LEVEL_CONTENT = "user://Level Content/words1.0.26.csv"


var INDEX_STORE = {}
var LEVEL_EDIT = []

var DATA_BOARD = []
var LIST_LEVEL = []
var LIST_WORDS = ""

var SIZE_W = 0
var SIZE_H = 0
var BOARD = []
var LEVEL_N_WORDS = ""

var SELECTED_CHAPTER = 0
var SELECTED_LEVEL = 0
var INDEX_SELECTED = ""

var BOARD_LEGIT = false
# save / load data:
# https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#editor-data-paths
# BOARD[col][row] is for coordinate in Godot


var LIST_OF_BLOCK = {}
var selected_id = null
var hover_word_list_id = null
var mouse_left_down = false
var current_mouspos_before_hold_down
var is_dragging = false
var distance = 0

var RPAD_MIN_LENGTH = 10


# var of UI
var Background
var Frontground
var BTN_save
var Response_vertical_box
var input_chapter
var input_level
var Wordlist_horizontal_box
var is_minimal = false
var control_zone

# SFX/BGM
var sfx_Card_pick
var sfx_Card_drop
var sfx_Btn_click
var sfx_Rotate
var sfx_invalid

var tween_parallel

var connected_id = []
var connected_letters = []
var connected_id_letters = {}
var current_letter_selected_id = null
var set_letter
var list_of_swipe_block = []
var max_stack = 0
var was_added_or_removed = false
var list_of_unlock_answer = []
var zone
var center

var label_connected_word
var background_connected_word
var background_1_letter_size = Vector2(120, 110) # 2 letter.x: 210, 4 letter.x: 280 -> 9 letter.x:245
var background_increase_step = 35
var hooray_moment_bg
var invalid_notif
var invalid_notif_text

var line
var was_add_point = false
var point_count = 0

var time_display
var time_start = 0
var time_now = 0
var is_time_started = false

var swipe_block_pos = []


# Called when the node enters the scene tree for the first time.
func _ready():
	
	Background = $Background
	Frontground = $Frontground
	BTN_save = $"../Control_zone/btn_save"
#	Response_vertical_box = $"../NinePatchRect/Error_List"
	input_chapter = $"../Control_zone/chapter_select/label_chapter/selected_chapter"
	input_level = $"../Control_zone/chapter_select/label_level/selected_level"
	Wordlist_horizontal_box = $Word_list_2
	control_zone = $"../Control_zone"
	
	sfx_Card_pick = $"../../Sound/SFX/Card_pick"
	sfx_Card_drop = $"../../Sound/SFX/Card_drop"
	sfx_Btn_click = $"../../Sound/SFX/Btn_click"
	sfx_Rotate = $"../../Sound/SFX/Card_shuffle"
	sfx_invalid = $"../../Sound/SFX/Word_invalid"
	
	zone = $"../Fixed_nodes/Swipe_zone_center"
	center = $"../Fixed_nodes/Swipe_zone_center/Center"
	
	background_connected_word = $"../Fixed_nodes/Connected_text"
	label_connected_word = $"../Fixed_nodes/Connected_text/Label"
	hooray_moment_bg = $"../Fixed_nodes/Hooray_moment"
	time_display = $"../Fixed_nodes/time_label"
	invalid_notif = $"../Fixed_nodes/Invalid_notif"
	invalid_notif_text = $"../Fixed_nodes/Invalid_notif/Label_color"
	
	line = $"../Fixed_nodes/Line"
	
	Background.visible = SETTING["showBackground"]


	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_left_down:
#		line.remove_point(-1)
		if len(connected_letters) > 0:
			line.set_point_position(point_count-1, get_viewport().get_mouse_position())
#		print(current_letter_selected_id)
		if not current_letter_selected_id == null:
			_add_or_remove_from_stack(current_letter_selected_id)
	
	
	if not mouse_left_down: # Left click release
#		print("you are free ")
		pass
		
	if is_time_started:
		time_now = Time.get_unix_time_from_system()
		var elapsed = time_now - time_start
		var minutes = elapsed / 60
		var seconds = int(fmod(elapsed , 60))
	#	int(fmod(selected_level , 100))
		var str_elapsed = "%02d : %02d" % [minutes, seconds]
#		print("elapsed : ", str_elapsed)
		time_display.text = str_elapsed


func _input( event ):
	
	if Input.is_action_pressed("ui_right"):
		_on_btn_load_pressed()
	
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
			is_dragging = true
#			line.add_point(get_viewport().get_mouse_position())
			
#			_play_sound("pick")
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false
			var answer_connected = "".join(connected_letters)
			

			
			if answer_connected in LEVEL_N_WORDS:
				var word_index = LEVEL_N_WORDS.find(answer_connected)
				if list_of_unlock_answer[word_index]:
					_show_already_found(answer_connected)
				else:
					_show_answer(word_index)
			else:
				_show_incorrect()
			
			if is_dragging:
				is_dragging = false
#				print(connected_id)
#				print(connected_letters)
				connected_id = []
				connected_letters = []
				connected_id_letters = {}
				
				was_added_or_removed = false
				point_count = 0
				
				for i in list_of_swipe_block:
					i._set_active(false)
					
				label_connected_word.text = ""
				background_connected_word.visible = false
				line.clear_points()


func _show_already_found(answer):
	invalid_notif_text.text = "[center][color=red]%s[/color] already found[/center]" % answer
	
	tween_parallel = get_tree().create_tween().set_parallel(true)
	
	invalid_notif.set("scale", Vector2(0,0))
	invalid_notif.set("position", invalid_notif.position + invalid_notif.size / 2)
	invalid_notif.set("visible", true)
	invalid_notif.set("modulate", Color.html("ffffff00"))
	
	tween_parallel.tween_property(
		invalid_notif,
		"scale",
		Vector2(1, 1),
		SETTING["animationSpeed"]
	)
	
	tween_parallel.tween_property(
		invalid_notif,
		"position",
		invalid_notif.position - invalid_notif.size / 2,
		SETTING["animationSpeed"]
	)
	
	tween_parallel.tween_property(
		invalid_notif,
		"modulate",
		Color.html("ffffff"),
		SETTING["animationSpeed"]
	)
	
	tween_parallel.tween_interval(1)
	
	tween_parallel.chain().tween_property(
		invalid_notif,
		"modulate",
		Color.html("ffffff00"),
		SETTING["animationSpeed"]
	)
	
	tween_parallel.chain().tween_property(
		invalid_notif,
		"scale",
		Vector2(0, 0),
		SETTING["animationSpeed"]
	)
	
	_show_incorrect()


func _show_incorrect():
	var current_pos
	for i in connected_id:
#		list_of_swipe_block[i] 
		tween_parallel = get_tree().create_tween().set_parallel(true)
		current_pos = list_of_swipe_block[i].position
		tween_parallel.tween_property(
			list_of_swipe_block[i],
			"position",
			current_pos + Vector2(10, 0),
			0.1
		)
		
		tween_parallel.chain().tween_property(
			list_of_swipe_block[i],
			"position",
			current_pos - Vector2(10, 0),
			0.1
		)
		
		tween_parallel.chain().tween_property(
			list_of_swipe_block[i],
			"position",
			current_pos,
			0.1
		)
	pass


func _show_answer(i):
	_show_hooray()
	
	for mob in Frontground.get_children():
		if mob.get_node("ID").text == str(i):
			mob.visible = true
			mob._set_active(true)
			_random_effect(mob)

			
	list_of_unlock_answer[i] = true
	if false not in list_of_unlock_answer:
		is_time_started = false
	
	pass


func _show_hooray():
	tween_parallel = get_tree().create_tween().set_parallel(true)
	
	hooray_moment_bg.set("scale", Vector2(0,0))
	hooray_moment_bg.set("position", hooray_moment_bg.position + hooray_moment_bg.size / 2)
	hooray_moment_bg.set("visible", true)
	hooray_moment_bg.set("modulate", Color.html("ffffff00"))
	
	tween_parallel.tween_property(
		hooray_moment_bg,
		"scale",
		Vector2(1, 1),
		SETTING["animationSpeed"]
	)
	
	tween_parallel.tween_property(
		hooray_moment_bg,
		"position",
		hooray_moment_bg.position - hooray_moment_bg.size / 2,
		SETTING["animationSpeed"]
	)
	
	tween_parallel.tween_property(
		hooray_moment_bg,
		"modulate",
		Color.html("ffffff"),
		SETTING["animationSpeed"]
	)
	
	tween_parallel.tween_interval(1)
	
	tween_parallel.chain().tween_property(
		hooray_moment_bg,
		"modulate",
		Color.html("ffffff00"),
		SETTING["animationSpeed"]
	)
	
	tween_parallel.chain().tween_property(
		hooray_moment_bg,
		"scale",
		Vector2(0, 0),
		SETTING["animationSpeed"]
	)


func _random_effect(mob):
	# random 1 - 4
	var case = randi() % 4 + 1
	
	tween_parallel = get_tree().create_tween().set_parallel(true)
	match case:
		1:
			var begin_pos = Vector2(0, 500)
			mob.set("position", mob.position - begin_pos)
			tween_parallel.tween_property(
				mob,
				"position", 
				mob.position + begin_pos, 
				SETTING["animationSpeed"]
			).set_trans(Tween.TRANS_EXPO)
		2:
			var begin_pos = Vector2(500, 0)
			mob.set("position", mob.position - begin_pos)
			tween_parallel.tween_property(
				mob,
				"position", 
				mob.position + begin_pos, 
				SETTING["animationSpeed"]
			).set_trans(Tween.TRANS_EXPO)
		3:
			var begin_pos = Vector2(0, 500)
			mob.set("position", mob.position + begin_pos)
			tween_parallel.tween_property(
				mob,
				"position", 
				mob.position - begin_pos, 
				SETTING["animationSpeed"]
			).set_trans(Tween.TRANS_EXPO)
		4:
			var begin_pos = Vector2(500, 0)
			mob.set("position", mob.position + begin_pos)
			tween_parallel.tween_property(
				mob,
				"position", 
				mob.position - begin_pos, 
				SETTING["animationSpeed"]
			).set_trans(Tween.TRANS_EXPO)
	pass


func _load_database(chapter):
	var path = PATH_CHAPTER % [chapter]
#	print(path)
	var content = FileAccess.get_file_as_string(path)
#	var content = file.get_file_as_string()
#	print(content)
	DATA_BOARD = JSON.parse_string(content)

#	print(DATA_BOARD)

	LIST_LEVEL = DATA_BOARD["ListLevelsInChapter"]

#	content = FileAccess.get_file_as_string("user://level-list.txt")
#	LIST_WORDS = content.split("\n")
	_get_data_from_csv()
	

func _get_data_from_csv():
	var csv = []
	var path = PATH_LEVEL_CONTENT
	
	LIST_WORDS = []
	var file = FileAccess.open(path, FileAccess.READ)
	while !file.eof_reached():
		var csv_rows = file.get_csv_line(",") # I use tab as delimiter
		csv.append(csv_rows)
	file.close()
	csv.pop_back() #remove last empty array get_csv_line() has created 
	var headers = Array(csv[0])
	
	# get data without header
	var csv_noheaders = csv.duplicate(true)
	csv_noheaders.remove_at(0) #remove first array (headers) from the csv

	
	# find column
	var column_name_id = headers.find("normal words")
	var level_id = 2
#	print(column_name_id)
#
#	print(csv_noheaders[level_id][column_name_id])
	
	
	for i in range(len(csv_noheaders)):
#		print(csv_noheaders[i - 2][column_name_id])
		LIST_WORDS.append(csv_noheaders[i][column_name_id])
	pass


func _save_database(chapter):
	var path = PATH_CHAPTER % [chapter]
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(JSON.stringify (DATA_BOARD, "\t"))
	file.close()


func _load_level(selected_level):
#    global SIZE_W, SIZE_H, BOARD, LEVEL_N_WORDS

	var level_n = LIST_LEVEL[int(fmod(selected_level , 100))]
	SIZE_W = level_n["h"]
	SIZE_H = level_n["w"]
	BOARD = level_n["b"]
	
	
	
	LEVEL_N_WORDS = []
	list_of_unlock_answer = []
	
	for i in LIST_WORDS[selected_level].split(" - "):
		LEVEL_N_WORDS.append(i.replace("\r","").to_upper())
		list_of_unlock_answer.append(false)



func _prepare_index_store():
	# draw the board and convert to array, also create board of index
	var row_ele_count = 0


	var board_array=[]
	for x in range(SIZE_W):
		board_array.append([])
		for y in range(SIZE_H):
			board_array[x].append(" ")
			
	var c_col = 0
	var c_row = 0

	# index_store = {
	#   1: [{"r": 0, "c": 0}, {"r": 0, "c": 1}, {"r": 0, "c": 2}]
	# }
	# which index 1 is WHO in horizontal and start at {"r": 0, "c": 0} in board_array
	INDEX_STORE = {}

	for cell in BOARD:
		# print(f"{cell['v']}", end=" ")
		# print(f"{c_row}, {c_col}")

		
		board_array[c_col][c_row] = cell['v']


		if not cell['v'] == ' ':
			if cell["i"] not in INDEX_STORE:
				INDEX_STORE[cell["i"]] = [{"r": c_row, "c": c_col}]
			else:
				INDEX_STORE[cell["i"]].append({"r": c_row, "c": c_col})

			if cell["ic"]:
				if cell["iw"] not in INDEX_STORE:
					INDEX_STORE[cell["iw"]] = [{"r": c_row, "c": c_col}]
				else:
					INDEX_STORE[cell["iw"]].append({"r": c_row, "c": c_col})

		row_ele_count += 1
		c_col += 1
		if row_ele_count == SIZE_W:
			# print()
			row_ele_count = 0
			c_row += 1
			c_col = 0


func _scale_up():

	LEVEL_EDIT = []
	for x in range(LEVEL_EDIT_SIZE):
		LEVEL_EDIT.append([])
		for y in range(LEVEL_EDIT_SIZE):
			LEVEL_EDIT[x].append(" ")
				
	var start_point_row = int((SIZE.row - SIZE_H) / 5)
	var start_point_col = int((SIZE.col - SIZE_W) / 2)
	
	
#	LIST_OF_BLOCK[selected_id][i].position = snapped(LIST_OF_BLOCK[selected_id][i].position, Vector2(55, 55))

	# import index_store to LEVEL_EDIT: scale coordinates to larger coordinates in LEVEL_EDIT
	for index in INDEX_STORE:
		for coor in INDEX_STORE[index]:
			coor["r"] += start_point_row
			coor["c"] += start_point_col


func _update_level_index():
	# convert word with index to LEVEL_EDIT from index_store
	for r in range(LEVEL_EDIT_SIZE):
		for c in range(LEVEL_EDIT_SIZE):

			var is_set = false  # check if set Letter for cell

			for index in INDEX_STORE:
				var i = 0  # index of a letter in word
				for coor in INDEX_STORE[index]:
					if r == coor["r"] and c == coor["c"]:
						LEVEL_EDIT[r][c] = LEVEL_N_WORDS[index][i]

						is_set = true
						break
					i += 1  # move to a next letter

			if not is_set:
				LEVEL_EDIT[r][c] = " "


func _print_level_edit():
	for n in Frontground.get_children():
		Frontground.remove_child(n)
		n.queue_free()
		
	for n in Background.get_children():
		Background.remove_child(n)
		n.queue_free()
		
	LIST_OF_BLOCK.clear()
		
#	print(INDEX_STORE)
#	print(LEVEL_N_WORDS)

	for i in INDEX_STORE:
		var pos_count = 0
		LIST_OF_BLOCK[i] = []
		for pos in INDEX_STORE[i]:
			var mob = block_letter.instantiate()
			mob.position = Vector2((START_POSITION.x + PADDING.top) * (pos["c"] + 1), 
				(START_POSITION.y + PADDING.right) * (pos["r"] + 1))
				
			mob.set("size", SETTING["letterSize"]["background"])
				
			mob.get_node("Letter").text = LEVEL_N_WORDS[i][pos_count]
			mob.get_node("Letter").set("theme_override_font_sizes/font_size", SETTING["letterSize"]["letter"])
			mob.get_node("ID").text = str(i)
			
			mob.visible = false
			
			mob.connect("you_are_hover_on", _on_moused_enter_item)
			mob.connect("you_are_exit", _on_moused_exit_item)
			
			var bg_mob = block_holder.instantiate()
			bg_mob.position = Vector2((START_POSITION.x + PADDING.top) * (pos["c"] + 1), 
				(START_POSITION.y + PADDING.right) * (pos["r"] + 1))
			bg_mob.set("size", SETTING["letterSize"]["background"])
			Background.add_child(bg_mob)
			
			pos_count += 1
			Frontground.add_child(mob)
			LIST_OF_BLOCK[i].append(mob)

	_test_spawn_swipe_block()
	time_start = Time.get_unix_time_from_system()
	is_time_started = true
#    set_process(true)
	pass


func _on_moused_exit_item(id):
	if selected_id == id and not is_dragging:
		selected_id = null


func _on_moused_enter_item(id):
#	print("Entered " + str(id) + " " + letter)
	if not is_dragging:
		selected_id = id


func _give_me_that_shit(chapter_id, level_id):
	_load_database(chapter_id)
	_load_level(level_id)
	_prepare_index_store()
	_scale_up()
	_update_level_index()
	_print_level_edit()
#	_check_valid()
	selected_id = null


func _save_to_file():
	_play_sound("click")
	var top_most_coor = LEVEL_EDIT_SIZE
	var left_most_coor = LEVEL_EDIT_SIZE
	var bottom_most_coor = 0
	var right_most_coor = 0
	
	for index in INDEX_STORE:
		for coor in INDEX_STORE[index]:
			if coor["r"] <= top_most_coor:
				top_most_coor = coor["r"]

			if coor["c"] <= left_most_coor:
				left_most_coor = coor["c"]
				
				
	# move all index in INDEX_STORE to fit coor
	for index in INDEX_STORE:
		for coor in INDEX_STORE[index]:
			coor["r"] -= top_most_coor
			coor["c"] -= left_most_coor

	for index in INDEX_STORE:
		for coor in INDEX_STORE[index]:
			if coor["r"] >= bottom_most_coor:
				bottom_most_coor = coor["r"]

			if coor["c"] >= right_most_coor:
				right_most_coor = coor["c"]

	right_most_coor += 1
	bottom_most_coor += 1

				
	var after_edit=[]
	for x in range(bottom_most_coor):
		after_edit.append([])
		for y in range(right_most_coor):
			after_edit[x].append(" ")

	for r in range(bottom_most_coor):
		for c in range(right_most_coor):

			var is_set = false  # check if set Letter for cell

			for index in INDEX_STORE:
				var i = 0  # index of letter in word
				for coor in INDEX_STORE[index]:
					if r == coor["r"] and c == coor["c"]:
						after_edit[r][c] = LEVEL_N_WORDS[index][i]
						is_set = true
						break
					i += 1  # move to next letter

			if not is_set:
				after_edit[r][c] = " "
	
#	print(after_edit)
	
	var output_lv = []
	for r in range(bottom_most_coor):
		for c in range(right_most_coor):
			if after_edit[r][c] == " ":
				output_lv.append(
					{'v': ' ', 'i': 0, 'ic': false, 'iw': 0}
					)
			else:
				var _temp = {'v': ' ', 'i': 0, 'ic': false, 'iw': 0}
				var is_check_cross = false  # True to continues search for crossword
				for index in INDEX_STORE:

					if not is_check_cross:
						for coor in INDEX_STORE[index]:
							if r == coor["r"] and c == coor["c"]:
								_temp['v'] = after_edit[r][c]
								_temp['i'] = index
								is_check_cross = true
								break
					else:
						for coor in INDEX_STORE[index]:
							if r == coor["r"] and c == coor["c"]:
								_temp['iw'] = index
								_temp['ic'] = true
								break

				output_lv.append(_temp)

#	print(output_lv)
	var _temp_save = {
		'w': bottom_most_coor,
		'h': right_most_coor,
		'b': output_lv
		}
	DATA_BOARD["ListLevelsInChapter"][int(fmod(SELECTED_LEVEL , 100))] = _temp_save
#	print(_temp_save)

	_save_database(SELECTED_CHAPTER)
	_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)


func _on_btn_load_pressed():
	_play_sound("click")
	SELECTED_LEVEL = float(input_level.text) - 1
	SELECTED_CHAPTER = int(SELECTED_LEVEL) / int(100)
	input_chapter.text = str(SELECTED_CHAPTER)
	input_level.text = str(SELECTED_LEVEL + 1)
	_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)


func _check_current_chapter():
	var readable_level = SELECTED_LEVEL + 1
	if readable_level >= 33:
		pass
	pass


func _on_btn_next_level_pressed():
	_play_sound("click")
	SELECTED_LEVEL += 1
	if SELECTED_LEVEL == 100:
		SELECTED_CHAPTER += 1
		input_chapter.text = str(SELECTED_CHAPTER)
	input_level.text = str(SELECTED_LEVEL + 1)
	_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)
	pass # Replace with function body.


func _on_btn_prev_level_2_pressed():
	_play_sound("click")
	if SELECTED_LEVEL > 0:
		SELECTED_LEVEL -= 1
		SELECTED_CHAPTER = int(SELECTED_LEVEL) / int(100)
		input_chapter.text = str(SELECTED_CHAPTER)
		input_level.text = str(SELECTED_LEVEL + 1)
		_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)
	pass # Replace with function body.


func _on_btn_prev_chapter_pressed():
	_play_sound("click")
	if SELECTED_CHAPTER > 0:
		SELECTED_CHAPTER -= 1
		SELECTED_LEVEL = SELECTED_CHAPTER * 100
		input_chapter.text = str(SELECTED_CHAPTER)
		input_level.text = str(SELECTED_LEVEL + 1)
		_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)
	pass # Replace with function body.


func _on_btn_next_chapter_pressed():
	_play_sound("click")
	SELECTED_CHAPTER += 1
	SELECTED_LEVEL = SELECTED_CHAPTER * 100
	input_chapter.text = str(SELECTED_CHAPTER)
	input_level.text = str(SELECTED_LEVEL + 1)
	_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)
	pass # Replace with function body.


func _play_sound(when):
	match when:
		"pick":
			sfx_Card_pick.play()
		"drop":
			sfx_Card_drop.play()
		"rotate":
			sfx_Rotate.play()
		"click":
			sfx_Btn_click.play()
		"error":
			sfx_invalid.play()


func _on_close_pressed():
	_play_sound("click")
	$"../Help_panel".visible = false
	pass # Replace with function body.


func _on_btn_help_pressed():
	_play_sound("click")
	$"../Help_panel".visible = true
	pass # Replace with function body.


func _test_spawn_swipe_block():
	
	list_of_swipe_block.clear()
	swipe_block_pos.clear()
	
	for n in zone.get_children():
		if n.name == "Center":
			continue
		zone.remove_child(n)
		n.queue_free()
	
	var radius = 225
	set_letter = LEVEL_N_WORDS[-1].split()
	var num_objects = len(set_letter)
	max_stack = num_objects

	var angle_increment = 360.0 / num_objects
	
#	print(num_objects)
#	print(set_letter)

	var spawm_pos = []
	
	for i in range(num_objects):
		# Calculate the angle for this object
		var angle_degrees = i * angle_increment

		# Convert the angle from degrees to radians
		var angle_radians = deg_to_rad(angle_degrees)

		# Calculate the position of the object based on the angle and radius
		var x = center.position.x - radius * sin(angle_radians) - SETTING["playtestSize"]["background"].x / 2
		var y = center.position.y - radius * cos(angle_radians) - SETTING["playtestSize"]["background"].y / 2


		spawm_pos.append(Vector2(x, y))
	
	for i in range(len(spawm_pos)):
		var rand_i = 0
		
		if len(spawm_pos) == 1:
			rand_i = 0
		else:
			rand_i = randi() % len(spawm_pos)
		
		# Instantiate the object and add it to the scene
		var mob = block_letter.instantiate()
		mob.position = spawm_pos[rand_i]
		
		mob.set("size", SETTING["playtestSize"]["background"])
				
		mob.get_node("Letter").text = set_letter[i]
		mob.get_node("ID").text = str(i)
		mob.get_node("Letter").set("theme_override_font_sizes/font_size", SETTING["playtestSize"]["letter"])
		
		mob.connect("you_are_hover_on", _on_add_letter_to_stack)
		mob.connect("you_are_exit", _on_move_to_next_letter)
		
#		print("connected func")
		zone.add_child(mob)
		list_of_swipe_block.append(mob)
		swipe_block_pos.append(mob.position)
		spawm_pos.remove_at(rand_i)


	pass


func _on_add_letter_to_stack(id):
#	print("Entered: " + set_letter[id])
	current_letter_selected_id = id
	

func _on_move_to_next_letter(id):
#	print("Exited: " + set_letter[id])
#	print(connected_id)
	current_letter_selected_id = null
	was_added_or_removed = false
	pass


func _update_something_when_add_or_remove_from_stack(id):
	connected_id.append(id)
	connected_letters.append(set_letter[id])
	list_of_swipe_block[id]._set_active(true)
	was_added_or_removed = true
	was_add_point = true
#	print("Add %s to stack %s" % [set_letter[id], connected_id])
	pass


func _add_or_remove_from_stack(id):
	
	var point = list_of_swipe_block[id].global_position + (list_of_swipe_block[id].size / 2)
	
	if len(connected_id) == 0 and not was_added_or_removed:
		_update_something_when_add_or_remove_from_stack(id)
		line.add_point(point)
		line.add_point(point)
		point_count += 2
		
		background_connected_word.visible = true
		label_connected_word.text = "".join(connected_letters)
		return
		
	if len(connected_id) == 1 and not was_added_or_removed:
		if id in connected_id:
			return
		
		if connected_id[0] == id:
			return
		
		if id in connected_id:
			return
		_update_something_when_add_or_remove_from_stack(id)
		line.set_point_position(point_count-1, point)
		line.add_point(point)
		point_count += 1
		label_connected_word.text = "".join(connected_letters)
		return

	
	if not was_added_or_removed:
		
		if connected_id[-1] == id:
			return
		if connected_id[-2] == id:
			
#			print("will Remove %s out of stack %s" % [connected_letters[-1], connected_id])
			list_of_swipe_block[connected_id[-1]]._set_active(false)
			
			connected_id.remove_at(len(connected_id)-1)
			connected_letters.remove_at(len(connected_letters)-1)
			line.remove_point(point_count - 1)
			point_count -= 1
			
#			print(connected_letters.size())
			was_added_or_removed = true
			label_connected_word.text = "".join(connected_letters)
			
			
		else:
			if len(connected_id) == max_stack:
				return
			if id in connected_id:
				return
			_update_something_when_add_or_remove_from_stack(id)
			line.set_point_position(point_count-1, point)
			line.add_point(point)
			point_count += 1
			label_connected_word.text = "".join(connected_letters)
	
	return


func _on_booster_shuffle_pressed():
	var temp_pos_list = swipe_block_pos.duplicate(true)
	var rand_pos

	for mob in list_of_swipe_block:
		
		var tw = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		
		if len(temp_pos_list) == 1:
			tw.tween_property(
				mob,
				"position",
				center.position - SETTING["playtestSize"]["background"] / 2,
				SETTING["animationSpeed"]
			)
			tw.tween_property(
				mob,
				"position",
				temp_pos_list[0],
				SETTING["animationSpeed"]
			)
			break
			
		rand_pos = temp_pos_list[randi() % temp_pos_list.size()]
		temp_pos_list.erase(rand_pos)
		print(len(temp_pos_list))
		
		tw.tween_property(
			mob,
			"position",
			center.position - SETTING["playtestSize"]["background"] / 2,
			SETTING["animationSpeed"]
		)
		
		tw.tween_property(
			mob,
			"position",
			rand_pos,
			SETTING["animationSpeed"]
		)
		
	
	pass # Replace with function body.


func _on_booster_hint_pressed():
	var is_revealed = false

	
	var current_letter_id_unrevealed = 0
	
	var most_loop = 100
	var current_loop = 0
	
	while current_loop < most_loop:
		
		for word_id in LIST_OF_BLOCK:
#			print(len(LIST_OF_BLOCK[word_id])) # 3
#			print(current_letter_id_unrevealed) # 2 is last item
			# if len(word) >= current_letter, then move to next word
			if current_letter_id_unrevealed >= len(LIST_OF_BLOCK[word_id]):
				continue
			
			
			if LIST_OF_BLOCK[word_id][current_letter_id_unrevealed].visible == false:
				
				LIST_OF_BLOCK[word_id][current_letter_id_unrevealed].visible = true
				LIST_OF_BLOCK[word_id][current_letter_id_unrevealed].modulate = 0
				LIST_OF_BLOCK[word_id][current_letter_id_unrevealed]._set_active(true)
				
				is_revealed = true
				
				tween_parallel = create_tween().set_parallel(true).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
				
				var particle = particle_booster.instantiate()
				$"..".add_child(particle)
				
				particle.position = get_viewport().get_mouse_position()
				
				tween_parallel.tween_property(
					particle,
					"position",
					LIST_OF_BLOCK[word_id][current_letter_id_unrevealed].global_position + 
					LIST_OF_BLOCK[word_id][current_letter_id_unrevealed].size / 2,
					1
				)
				
				tween_parallel.chain().tween_callback(particle.queue_free)
				tween_parallel.chain().tween_callback(LIST_OF_BLOCK[word_id][current_letter_id_unrevealed].set.bind("modulate", Color.html("ffffff")))
				
#				
			
			if is_revealed:
				break
				
		current_letter_id_unrevealed += 1
		current_loop += 1
		
		if is_revealed:
			break

	for i in LIST_OF_BLOCK:
		var temp_visible = []
		for letter in LIST_OF_BLOCK[i]:
			temp_visible.append(letter.visible)
		
		if false not in temp_visible:
			list_of_unlock_answer[i] = true
			if false not in list_of_unlock_answer:
				is_time_started = false
	
#	list_of_unlock_answer[i] = true
#	if false not in list_of_unlock_answer:
#		is_time_started = false


func _on_booster_touch_pressed():
	pass # Replace with function body.


func _on_booster_icon_pressed():
	pass # Replace with function body.


func _on_btn_hide_pressed():
	tween_parallel = create_tween()
	
	if not is_minimal:
#		is_minimal = true
#		minimal_error_list.visible = true
		$"../btn_hide".set("flip_h", true)
#		old_position = control_zone.position
#		control_zone.position.x += control_zone.size.x
		
		tween_parallel.tween_property(
			control_zone,
			"position:x",
			control_zone.position.x + control_zone.size.x,
			0.1
		)
		tween_parallel.tween_callback(_trigger_is_minimal)
		
	else:
#		is_minimal = false
#		minimal_error_list.visible = false
		$"../btn_hide".set("flip_h", false)
		tween_parallel.tween_property(
			control_zone,
			"position:x",
			control_zone.position.x - control_zone.size.x,
			0.1
		)
		tween_parallel.tween_callback(_trigger_is_minimal)
	pass # Replace with function body.
	

func _trigger_is_minimal():
#	print(SETTING)
	is_minimal = !is_minimal
