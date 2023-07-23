extends Control

@export var block_holder: PackedScene
@export var block_letter: PackedScene
@export var responser: PackedScene
@export var btn_word: PackedScene


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
	"animationSpeed": 0.1,
	"playtestSize": {
		"background": Vector2(100, 100), # Default: Vector2(50, 50)
		"letter": 65 # Default: 35. Background increse 10 then letter increase 5 
	}
}

var START_POSITION = SETTING["letterSize"]["background"]

var LEVEL_EDIT_SIZE = 20
var SIZE = {"row": LEVEL_EDIT_SIZE, "col": LEVEL_EDIT_SIZE}
var PADDING = {"top": 5, "right": 5, "bottom": 0, "left": 0}

var BOARD_BG = []
var BOARD_FG = []

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
var current_letter_conncet = null
var set_letter
var list_of_swipe_block = []
var max_stack = 0
var was_added_or_removed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	print(OS.get_name())
	if OS.get_name() == "Windows":
		print("Resize for Windows")
		DisplayServer.window_set_size(Vector2(1100,800))
		DisplayServer.window_set_position(Vector2(200, 200))
	
	Background = $Background
	Frontground = $Frontground
	BTN_save = $"../Controll_zone/btn_save"
#	Response_vertical_box = $"../NinePatchRect/Error_List"
	input_chapter = $"../Controll_zone/chapter_select/label_chapter/selected_chapter"
	input_level = $"../Controll_zone/chapter_select/label_level/selected_level"
	Wordlist_horizontal_box = $Word_list_2
	
	sfx_Card_pick = $"../../Sound/SFX/Card_pick"
	sfx_Card_drop = $"../../Sound/SFX/Card_drop"
	sfx_Btn_click = $"../../Sound/SFX/Btn_click"
	sfx_Rotate = $"../../Sound/SFX/Card_shuffle"
	sfx_invalid = $"../../Sound/SFX/Word_invalid"
	
	Background.visible = SETTING["showBackground"]
	
#	if SETTING["showBlockHolder"]:
#		for r in range(0, SIZE.row):
#			var row = []
#			for c in range(0, SIZE.col):
#				var mob = block_holder.instantiate()
#				mob.position = Vector2((START_POSITION.x + PADDING.top) * (c + 1), 
#					(START_POSITION.y + PADDING.right) * (r + 1))
#				Background.add_child(mob)
#				row.append(mob)
#	#			print("Install block " + str(mob.position.x) + ", " + str(mob.position.y))
#			BOARD_BG.append(row)

	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_left_down:
		is_dragging = true
#		print(current_letter_conncet)
		if not current_letter_conncet == null:
			_add_or_remove_from_stack(current_letter_conncet)
	
	
	if not mouse_left_down: # Left click release
#		print("you are free ")
		if is_dragging:
			is_dragging = false
			print(connected_id)
			print(connected_letters)
			connected_id = []
			connected_letters = []
			connected_id_letters = {}
			current_letter_conncet = null
			
			
			for i in list_of_swipe_block:
				i._set_active(false)


func _input( event ):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
#			_play_sound("pick")
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false
#			_play_sound("drop")
			


func _load_database(chapter):
	var path = "user://chapter%d.json" % [chapter]
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
	LIST_WORDS = []
	var file = FileAccess.open("user://words1.0.26.csv", FileAccess.READ)
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
	var path = "user://chapter%d.json" % [chapter]
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
	
	for i in LIST_WORDS[selected_level].split(" - "):
		LEVEL_N_WORDS.append(i.replace("\r","").to_upper())


func _set_active_items(id, is_active, type=1):
	for letter in LIST_OF_BLOCK[id]:
		letter._set_active(is_active, type)


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

	# insert board into bigger board 25x25

				
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
			Background.add_child(bg_mob)
			
			pos_count += 1
			Frontground.add_child(mob)
			LIST_OF_BLOCK[i].append(mob)
#		print(LIST_OF_BLOCK[i])

	_test_spawn_swipe_block()

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
	
	var zone = $"../Controll_zone/Swipe_zone_center"
	var center = $"../Controll_zone/Swipe_zone_center/Center"
	
	list_of_swipe_block.clear()
	
	for n in zone.get_children():
		if n.name == "Center":
			continue
		zone.remove_child(n)
		n.queue_free()
	
	var radius = 200
	set_letter = LEVEL_N_WORDS[-1].split()
	var num_objects = len(set_letter)
	max_stack = num_objects

	var angle_increment = 360.0 / num_objects
	
	print(num_objects)
	print(set_letter)
	
	for i in range(num_objects):
		# Calculate the angle for this object
		var angle_degrees = i * angle_increment

		# Convert the angle from degrees to radians
		var angle_radians = deg_to_rad(angle_degrees)

		# Calculate the position of the object based on the angle and radius
		var x = center.position.x - radius * sin(angle_radians) - SETTING["playtestSize"]["background"].x / 2
		var y = center.position.y - radius * cos(angle_radians) - SETTING["playtestSize"]["background"].y / 2

		# Instantiate the object and add it to the scene
		var mob = block_letter.instantiate()

		# Set the position of the object
		mob.position = Vector2(x, y)
		
		mob.set("size", SETTING["playtestSize"]["background"])
				
		mob.get_node("Letter").text = set_letter[i]
		mob.get_node("ID").text = str(i)
		mob.get_node("Letter").set("theme_override_font_sizes/font_size", SETTING["playtestSize"]["letter"])
		
		mob.connect("you_are_hover_on", _on_add_letter_to_stack)
		mob.connect("you_are_exit", _on_move_to_next_letter)
		
		print("connected func")
		zone.add_child(mob)
		list_of_swipe_block.append(mob)


	pass

func _on_add_letter_to_stack(id):
#	print("Entered: " + set_letter[id])
	current_letter_conncet = id
	

func _on_move_to_next_letter(id):
#	print("Exited: " + set_letter[id])
#	print(connected_id)
	current_letter_conncet = null
	was_added_or_removed = false
	pass

func _add_or_remove_from_stack(id):
	
#	print("Im triggered...")
	
	if len(connected_id) == 0 and not was_added_or_removed:
		connected_id.append(id)
		connected_letters.append(set_letter[id])
		list_of_swipe_block[id]._set_active(true)
		was_added_or_removed = true
		print("Add %s to stack %s" % [set_letter[id], connected_id])
		return
		
	if len(connected_id) == 1 and not was_added_or_removed:
		if connected_id[0] == id:
			return
		connected_id.append(id)
		connected_letters.append(set_letter[id])
		print("Add %s to stack %s" % [set_letter[id], connected_id])
		list_of_swipe_block[id]._set_active(true)
		was_added_or_removed = true
		return
	
#	if len(connected_id) == 2 and not was_added_or_removed:
#		if connected_id[1] == id:
#			return
#		if connected_id[0] == id:
#			print("Remove %s out of stack %s" % [set_letter[connected_id[-1]], connected_id])
#			connected_id.remove_at(1)
#			connected_letters.remove_at(1)
#			list_of_swipe_block[connected_id[-1]]._set_active(false)
#			was_added_or_removed = true
#		else:
#			if len(connected_id) == max_stack:
#				return
#			connected_id.append(id)
#			connected_letters.append(set_letter[id])
#			print("Add %s to stack %s" % [set_letter[id], connected_id])
#			list_of_swipe_block[id]._set_active(true)
#			was_added_or_removed = true
#		return
	
	if not was_added_or_removed:
		if connected_id[-1] == id:
			return
		if connected_id[-2] == id:
			
			print("will Remove %s out of stack %s" % [connected_letters[-1], connected_id])
			list_of_swipe_block[connected_id[-1]]._set_active(false)
			
			connected_id.remove_at(len(connected_id)-1)
			connected_letters.remove_at(len(connected_letters)-1)
			
			print(connected_letters.size())
			was_added_or_removed = true
			
		else:
			if len(connected_id) == max_stack:
				return
			connected_id.append(id)
			connected_letters.append(set_letter[id])
			print("Add %s to stack %s" % [set_letter[id], connected_id])
			list_of_swipe_block[id]._set_active(true)
			was_added_or_removed = true
	
	return
#	print(connected_id)