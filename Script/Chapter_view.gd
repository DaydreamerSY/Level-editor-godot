extends Control

@export var block_letter : PackedScene
@export var chapter_item : PackedScene

var scroll_container

var PATH_CHAPTER = "user://Level Layout/chapter%d.json"
var PATH_LEVEL_CONTENT = "user://Level Content/words1.0.26.csv"

var DATA_BOARD = []
var LIST_LEVEL = []
var LIST_WORDS = ""

var SELECTED_CHAPTER = 0
var input_chapter

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
	_load_chapter_view()
	pass # Replace with function body.
