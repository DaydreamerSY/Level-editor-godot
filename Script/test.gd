extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
#	_load_csv()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _load_csv():
	var csv = []
	var file = FileAccess.open("user://words1.0.26.csv", FileAccess.READ)
	while !file.eof_reached():
		var csv_rows = file.get_csv_line(",") # I use tab as delimiter
		csv.append(csv_rows)
	file.close()
#	csv.pop_back() #remove last empty array get_csv_line() has created 
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
	print(len(csv))
	print(csv[6000])
	print(len(csv_noheaders))
	print(csv_noheaders[5999])
#	for i in range(len(csv)):
#		if csv_noheaders[i] == csv[i]:
#			print(i)
#		print(csv_noheaders[i - 2][column_name_id])






func _on_playtest_mode_pressed():
	$".".visible = false
	$"../Playtest_mode".visible = true
	$"../Playtest_mode/Control_zone/chapter_select/label_level/selected_level".text = $Control_zone/chapter_select/label_level/selected_level.text
	$"../Playtest_mode/Edit_zone"._on_btn_load_pressed()


func _on_edit_mode_pressed():
	$".".visible = true
	$"../Playtest_mode".visible = false
	$Control_zone/chapter_select/label_level/selected_level.text = $"../Playtest_mode/Control_zone/chapter_select/label_level/selected_level".text
	$Edit_zone._on_btn_load_pressed()
