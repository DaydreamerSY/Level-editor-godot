extends Control

@export var _vid_length : float
@export var _fade_delay: float
@export var _video : String

@export var Background_vid : VideoStreamPlayer

var bg_1
var bg_2
var current_vid_playing = 0

var current_video_time = 0
var time_now
var time_start

var is_play = false

var tween
var old_vid

# Called when the node enters the scene tree for the first time.
func _ready():
#	bg_1 = $Background_vid
#	bg_2 = $Background_vid_2
#
#	bg_1.stream = load(_video)
#	bg_2.stream = load(_video)
#	bg_2.play()
#	current_vid_playing = 2
#
#	if _fade_delay == 0:
#		bg_2.connect("finished", bg_2.play)
#		pass
#
#	time_start = Time.get_unix_time_from_system()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	if not player.is_playing():
#		player.play()
#	time_now = Time.get_unix_time_from_system()
#	var elapsed = round(time_now - time_start)
#	var minutes = elapsed / 60
#	var seconds = int(fmod(elapsed , 60))
#	var str_elapsed = "%02d : %02d" % [minutes, seconds]
#	print("elapsed : ", elapsed)
	

#	if elapsed >= (_vid_length - _fade_delay):
#		_switch_video()
#		print("Current video playing: %s" % [current_vid_playing])

	pass


#func _replay():
#	bg_2.play()


func _switch_video():
	tween = create_tween()
	
	match current_vid_playing:
		1:
			bg_2.play()
			time_start = Time.get_unix_time_from_system()
			
			tween.tween_property(
				bg_1,
				"modulate",
				Color.html("ffffff00"), # fade out
				_fade_delay
			)
			tween.tween_callback(_move_to_behind)
#			tween.tween_callback(self.set.bind(move_child, [bg_1, 0]))
#			tween.tween_callback(bg_1.set.bind("set", ["modulate", Color.html("ffffff")]))
#			self.move_child(bg_1,0)
#			bg_1.set("modulate", Color.html("ffffff"))
	
		2:
			bg_1.play()
			time_start = Time.get_unix_time_from_system()
	
			tween.tween_property(
				bg_2,
				"modulate",
				Color.html("ffffff00"), # fade out
				_fade_delay
			)
			tween.tween_callback(_move_to_behind)
#			tween.tween_callback(self.set.bind(move_child, [bg_2, 0]))
#			tween.tween_callback(bg_2.set.bind("set", ["modulate", Color.html("ffffff")]))
#			self.move_child(bg_2,0)
#			bg_2.set("modulate", Color.html("ffffff"))
	

func _move_to_behind():
	match current_vid_playing:
		1:
			self.move_child(bg_1, 0)
			bg_1.set("modulate", Color.html("ffffff"))
			current_vid_playing = 2
			pass
		2:
			self.move_child(bg_2, 0)
			bg_2.set("modulate", Color.html("ffffff"))
			current_vid_playing = 1
			pass
	pass



func _load_ogv(path):
	bg_1.stream = load(path)
	bg_2.stream = load(path)
	bg_2.play()
	current_vid_playing = 2
	time_start = Time.get_unix_time_from_system()
	pass
