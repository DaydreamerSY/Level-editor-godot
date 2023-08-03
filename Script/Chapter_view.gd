extends Control

@export var block_letter : PackedScene
@export var chapter_item : PackedScene

var scroll_container

var PATH_CHAPTER = "user://Level Layout/chapter%d.json"
var PATH_LEVEL_CONTENT = "user://Level Content/words1.0.26.csv"

var DATA_BOARD = []
var LIST_LEVEL = []
var LIST_WORDS = ""

var HEADER
var CSV_DATA = []
var LEVEL_CONTENT_COL_ID = 0

var SELECTED_CHAPTER = 0
var input_chapter

var default_warning_text = """
- When SWAP, application will freeze in a short of time, don't spam.
- Please don't spam.
- Again: don't spam anything.
- Spam at your own risk.
- Developer will NOT take any responsibility.
- I'll disable button for you.
- Don't try to spam or you will get f**ked... by yourself :D

--Thanks! 
"""

var default_ok_text = "\nOk, now you can close this pop-up, thanks for your patient"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	input_chapter = $"../Control_zone/chapter_select/label_chapter/selected_chapter"
	scroll_container = $MarginContainer/ScrollContainer/VBoxContainer
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _load_chapter_view():
	
	for i in scroll_container.get_children():
		i.queue_free()
	
	_load_database(SELECTED_CHAPTER)
	var count = 1
	for level in LIST_LEVEL:
		_add_level("Level %s" % [SELECTED_CHAPTER * 100 + count], level)
		count += 1
	

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
#	_save_data_to_csv()
#	_swap_level(160, 161)


func _save_database(chapter):
	var path = PATH_CHAPTER % [chapter]
#	var path = "user://test_swap.json"
	var file = FileAccess.open(path, FileAccess.WRITE) 
	file.store_line(JSON.stringify (DATA_BOARD, "\t"))
	file.close()


func _get_data_from_csv():
	var csv = []
	CSV_DATA.clear()
	var path = PATH_LEVEL_CONTENT
	
	LIST_WORDS = []
	var file = FileAccess.open(path, FileAccess.READ)
	while !file.eof_reached():
		var csv_rows = file.get_csv_line(",") # I use tab as delimiter
		csv.append(csv_rows)
	file.close()
	csv.pop_back() #remove last empty array get_csv_line() has created 
	HEADER = Array(csv[0])
	
	# get data without header
	var csv_noheaders = csv.duplicate(true)
	csv_noheaders.remove_at(0) #remove first array (headers) from the csv

	
	# find column
	LEVEL_CONTENT_COL_ID = HEADER.find("normal words")
	
	CSV_DATA.append(HEADER)
	
	for i in range(len(csv_noheaders)):
#		print(csv_noheaders[i - 2][column_name_id])
#		i is row
		LIST_WORDS.append(csv_noheaders[i][LEVEL_CONTENT_COL_ID])
		CSV_DATA.append(csv_noheaders[i])
			
	pass


func _save_data_to_csv():
	var file = FileAccess.open(PATH_LEVEL_CONTENT, FileAccess.WRITE)
	
	print(len(CSV_DATA))
	
	for line in CSV_DATA:
		file.store_line(",".join(line))
#	file.store_csv_line(CSV_DATA)
#	for line in CSV_DATA:
#		file.store_csv_line(line)
	file.close()
	pass


func _swap_level(a, b):
	
	var _selected_level_a = a - 1
	var _selected_level_b = b - 1
	
	var _temp_level = DATA_BOARD["ListLevelsInChapter"][int(fmod(_selected_level_a , 100))]
	DATA_BOARD["ListLevelsInChapter"][int(fmod(_selected_level_a , 100))] = DATA_BOARD["ListLevelsInChapter"][int(fmod(_selected_level_b , 100))]
	DATA_BOARD["ListLevelsInChapter"][int(fmod(_selected_level_b , 100))] = _temp_level
	
	
	var _temp_content = CSV_DATA[a][LEVEL_CONTENT_COL_ID]
	CSV_DATA[a][LEVEL_CONTENT_COL_ID] = CSV_DATA[b][LEVEL_CONTENT_COL_ID]
	CSV_DATA[b][LEVEL_CONTENT_COL_ID] = _temp_content
	
	_save_database(SELECTED_CHAPTER)
	_save_data_to_csv()
	
	return [a, b]


func _add_level(name, level):
	var col = level["h"]
	var level_item = chapter_item.instantiate()
	
	level_item.get_node("Level_name").text = name
	level_item.get_node("Level_content").set("columns", col)
	
	for cell in level["b"]:
		if cell["v"] == " ":
			var _temp = Control.new()
			level_item.get_node("Level_content").add_child(_temp)
		else:
			var _temp = block_letter.instantiate()
			
			_temp.get_node("Letter").text = cell["v"]
			_temp.set("custom_minimum_size", Vector2(50, 50))
			_temp.set("mouse_filter", "ignore")
			
			level_item.get_node("Level_content").add_child(_temp)
	
	
	scroll_container.add_child(level_item)
	pass


func _on_btn_prev_chapter_pressed():
	if SELECTED_CHAPTER > 0:
		SELECTED_CHAPTER -= 1
		input_chapter.text = str(SELECTED_CHAPTER)
		_load_chapter_view()
	pass # Replace with function body.


func _on_btn_next_chapter_pressed():
	SELECTED_CHAPTER += 1
	input_chapter.text = str(SELECTED_CHAPTER)
	_load_chapter_view()
	pass # Replace with function body.


func _on_btn_load_pressed():
	SELECTED_CHAPTER = int(input_chapter.text)
	_load_chapter_view()
	pass # Replace with function body.


func _on_btn_swap_pressed():
	$"../../Popups-notif/Swap_warning/chapter_select/btn_swap_close".visible = false
	$"../../Popups-notif/Swap_warning".visible = true
	$"../Control_zone/btn_swap".visible = false
	$"../../Popups-notif/Swap_warning/chapter_select/MarginContainer/Tip".text = default_warning_text

	
	await get_tree().create_timer(1.0).timeout
	
	var level_a = int($"../Control_zone/chapter_select/label_swap_level/level_a".text)
	var level_b = int($"../Control_zone/chapter_select/label_swap_level/level_b".text)
	
	LIST_LEVEL = DATA_BOARD["ListLevelsInChapter"]
	
	_swap_level(level_a, level_b)
	_load_chapter_view()
	
	$"../Control_zone/btn_swap".visible = true
	$"../../Popups-notif/Swap_warning/chapter_select/MarginContainer/Tip".text += default_ok_text
	$"../../Popups-notif/Swap_warning/chapter_select/btn_swap_close".visible = true
	pass # Replace with function body.
