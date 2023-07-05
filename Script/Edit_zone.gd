extends Control

@export
var block_holder: PackedScene

@export
var block_letter: PackedScene

var label_error


var START_POSITION = Vector2(50, 50)

var SIZE = {"row": 20, "col": 20}
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

var LEVEL_EDIT_SIZE = 20

var SELECTED_CHAPTER = "chapter0"
var SELECTED_LEVEL = 0
var INDEX_SELECTED = ""


var Background
var Frontground
# save / load data:
# https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html#editor-data-paths
# BOARD[col][row] is for coordinate in Godot


var LIST_OF_BLOCK = {}
var selected_id = null
var mouse_left_down = false
var current_mouspos_before_hold_down
var is_dragging = false
var distance = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	
	Background = $Background
	Frontground = $Frontground
	label_error = $"../Controll_zone/Error"
	
	for r in range(0, SIZE.row):
		var row = []
		for c in range(0, SIZE.col):
			var mob = block_holder.instantiate()
			mob.position = Vector2((START_POSITION.x + PADDING.top) * (c + 1), 
				(START_POSITION.y + PADDING.right) * (r + 1))
			Background.add_child(mob)
			row.append(mob)
#			print("Install block " + str(mob.position.x) + ", " + str(mob.position.y))
		BOARD_BG.append(row)

	
#	print(BOARD_BG[3][1])
#	_set_letter(BOARD_BG[3][1], "A")
#	_get_letter(BOARD_BG[3][1])
#	_load_database("chapter0")
#	_load_level(1)
#	_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if mouse_left_down and not selected_id == null: # Left click hold dowm
#		print("you are holding " + LEVEL_N_WORDS[selected_id])
#		print(get_viewport().get_mouse_position())
		
		if not is_dragging:
			is_dragging = true
			current_mouspos_before_hold_down = get_viewport().get_mouse_position()
		
		distance = get_viewport().get_mouse_position() - current_mouspos_before_hold_down
#		print("Mouse move to " + str(get_viewport().get_mouse_position()) +" with distance " + str(distance))
		if not distance == Vector2(0, 0):
			_update_new_pos(distance)
			current_mouspos_before_hold_down = get_viewport().get_mouse_position()
	
	
	if not mouse_left_down: # Left click release
#		print("you are free ")
		if is_dragging:
			is_dragging = false
			distance = 0
			_snaped_pos()


func _input( event ):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false
			
	if event is InputEventMouseButton and not selected_id == null:
		if event.button_index == 2 and event.is_pressed():
			_rotate()
#			print(INDEX_STORE[selected_id])


func _load_database(file_name):
	var path = "user://" + file_name + ".json"
#	print(path)
	var content = FileAccess.get_file_as_string(path)
#	var content = file.get_file_as_string()
#	print(content)
	DATA_BOARD = JSON.parse_string(content)

#	print(DATA_BOARD)

	LIST_LEVEL = DATA_BOARD["ListLevelsInChapter"]

	content = FileAccess.get_file_as_string("user://level-list.txt")
#	content = file.get_as_text()
	LIST_WORDS = content.split("\n")


func _save_database(file_name):
	var path = "user://" + file_name + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_line(JSON.stringify (DATA_BOARD, "\t"))
	file.close()
#	DATA_BOARD = JSON.parse_string(content)


func _load_level(selected_level):
#    global SIZE_W, SIZE_H, BOARD, LEVEL_N_WORDS

	var level_n = LIST_LEVEL[selected_level]
	SIZE_W = level_n["h"]
	SIZE_H = level_n["w"]
	BOARD = level_n["b"]
	
	LEVEL_N_WORDS = []
	
	for i in LIST_WORDS[selected_level].split(" - "):
		LEVEL_N_WORDS.append(i.replace("\r","").to_upper())
	
#	print(BOARD)


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
				
	var start_point_row = int((SIZE.row - SIZE_W) / 2)
	var start_point_col = int((SIZE.col - SIZE_H) / 2)
	
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
		
#	print(INDEX_STORE)
#	print(LEVEL_N_WORDS)

	for i in INDEX_STORE:
		var pos_count = 0
		LIST_OF_BLOCK[i] = []
		for pos in INDEX_STORE[i]:
			var mob = block_letter.instantiate()
			mob.position = Vector2((START_POSITION.x + PADDING.top) * (pos["c"] + 1), 
				(START_POSITION.y + PADDING.right) * (pos["r"] + 1))
				
			mob.get_node("Letter").text = LEVEL_N_WORDS[i][pos_count]
			mob.get_node("ID").text = str(i)
			
			mob.connect("you_are_hover_on", _on_moused_enter_item)
			mob.connect("you_are_exit", _on_moused_exit_item)
			
			pos_count += 1
			Frontground.add_child(mob)
			LIST_OF_BLOCK[i].append(mob)
#		print(LIST_OF_BLOCK[i])

	pass
	
	
func _on_moused_exit_item(id):
	if selected_id == id and not is_dragging:
		selected_id = null


func _on_moused_enter_item(id, letter):
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
	selected_id = null


func _update_new_pos(distance):
	for mob in LIST_OF_BLOCK[selected_id]:
		
		mob.position += distance


func _snaped_pos():
		
	for i in range(len(LIST_OF_BLOCK[selected_id])):
		LIST_OF_BLOCK[selected_id][i].position = snapped(LIST_OF_BLOCK[selected_id][i].position, Vector2(55, 55))

		INDEX_STORE[selected_id][i]["r"] += LIST_OF_BLOCK[selected_id][i].position.y / 55 - INDEX_STORE[selected_id][i]["r"] -1
		INDEX_STORE[selected_id][i]["c"] += LIST_OF_BLOCK[selected_id][i].position.x / 55 - INDEX_STORE[selected_id][i]["c"] -1
#		print(INDEX_STORE[selected_id][i])
#		print(LIST_OF_BLOCK[selected_id][i].position / Vector2(55, 55))
#		print("r need to + " + str(LIST_OF_BLOCK[selected_id][i].position.y / 55 - INDEX_STORE[selected_id][i]["r"]))
#		print("c need to + " + str(LIST_OF_BLOCK[selected_id][i].position.x / 55 - INDEX_STORE[selected_id][i]["c"]))
#	print()
	print(_check_valid())

func _rotate():
	var first_coor = INDEX_STORE[selected_id][0]
	var second_coor = INDEX_STORE[selected_id][1]

	if second_coor["r"] == first_coor["r"] + 1:
#		print("Word in vertical")
		_rotate_horizontal()
		return

	if second_coor["c"] == first_coor["c"] + 1:
#        print("Word in horizontal")
		_rotate_vertical()
		return


func _rotate_horizontal():
	var step = 0
	for coor in INDEX_STORE[selected_id]:
		coor["r"] -= step
		coor["c"] += step
		step += 1
	
	step = 0
	for coor in LIST_OF_BLOCK[selected_id]:
		coor.position.y -= step  * 55
		coor.position.x += step * 55
		step += 1


func _rotate_vertical():
	var step = 0

	for coor in INDEX_STORE[selected_id]:
		coor["r"] += step
		coor["c"] -= step
		step += 1
	
	step = 0
	for coor in LIST_OF_BLOCK[selected_id]:
		coor.position.y += step * 55
		coor.position.x -= step * 55
		step += 1


func _save_to_file():
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

	print(output_lv)
	var _temp_save = {
		'w': bottom_most_coor,
		'h': right_most_coor,
		'b': output_lv
		}
	DATA_BOARD["ListLevelsInChapter"][SELECTED_LEVEL] = _temp_save
#	print(_temp_save)

	_save_database(SELECTED_CHAPTER)
	_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)


func _on_btn_load_pressed():
	SELECTED_CHAPTER = $"../Controll_zone/chapter_select/background/label_chapter/selected_chapter".text
	SELECTED_LEVEL = float($"../Controll_zone/chapter_select/background/label_level/selected_level".text) - 1
	_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)


func _on_btn_next_level_pressed():
	if SELECTED_LEVEL < 100:
		SELECTED_LEVEL += 1
		_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)
		$"../Controll_zone/chapter_select/background/label_level/selected_level".text = str(SELECTED_LEVEL + 1)
	pass # Replace with function body.


func _on_btn_prev_level_2_pressed():
	if SELECTED_LEVEL > 0:
		SELECTED_LEVEL -= 1
		_give_me_that_shit(SELECTED_CHAPTER, SELECTED_LEVEL)
		$"../Controll_zone/chapter_select/background/label_level/selected_level".text = str(SELECTED_LEVEL + 1)
	pass # Replace with function body.


func _check_valid():
	
#	check valid if:
#		board ko tạo ra từ nào ko có trong list, theo Horizontal và Vertical
#		board ko có 2 letter khác nhau trong cùng 1 vị trí	
	

	var current_letter_index = 0
	
	var next_letter_index = 0
	
	# check 2 letter ko trùng nhau trong cùng 1 vị trí
	for i in INDEX_STORE:
		
		current_letter_index = 0
		for letter_coor in INDEX_STORE[i]:
			
#			print(letter_coor) # { "r": 8, "c": 8 }
#			print(current_letter_index) # 0, đoạn này nghĩa là: tại vị trí letter_coor là letter thứ current_letter_count của word
			
			for j in INDEX_STORE: # loop through đám còn lại trong index store, kiểm tra lại vs đoạn trên
				if j == i:
					continue # pass qua current word's index
				else:
					next_letter_index = 0
					for next_letter_coor in INDEX_STORE[j]:
#						print(next_letter_coor)
#						print(letter_coor)
#						print(next_letter_coor == letter_coor)
#						print()
						if next_letter_coor["r"] == letter_coor["r"] and next_letter_coor["c"] == letter_coor["c"]: # nếu trùng vị trí thì check value của 2 word
							if not LEVEL_N_WORDS[int(i)][current_letter_index] == LEVEL_N_WORDS[int(j)][next_letter_index]:
#								print(LEVEL_N_WORDS[int(i)][current_letter_index])
#								print(LEVEL_N_WORDS[int(j)][next_letter_index])
								_show_error("over_lap_letter")
								print("Error here: " + LEVEL_N_WORDS[int(i)][current_letter_index] + " " + LEVEL_N_WORDS[int(j)][next_letter_index])
								return false # return false if 2 letter cùng vị trí khác giá trị
						else:
							next_letter_index += 1 # move to next letter of next word
#							continue
#						print()
						
			current_letter_index += 1 # move to next letter of current word
	
	_show_error("it_fine_bro")
	return true
	

func _show_error(error_code):
	match error_code:
		"over_lap_letter":
#			print("2 or more Letters have been overlaped") 
#			label_error.text = "2 or more Letters have been overlaped"
			_update_error("2 or more Letters overlaped", "red")
		"it_fine_bro":
			print("It fine bro!")
	pass


func _update_error(error_text, color):
	label_error.text = error_text
	label_error.set("theme_override_colors/font_color", Color(1, 0, 0))
	pass
