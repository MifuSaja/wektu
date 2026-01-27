extends Node

# Setting up the variables
# Analog node variables.
@onready var base_number = $Analog/BaseNumber
@onready var hour_needle = $Analog/HourNeedle
@onready var minute_needle = $Analog/MinuteNeedle
@onready var second_needle = $Analog/SecondNeedle
@onready var am_pm = $Analog/AmPm
@onready var main_camera = $MainCamera

# Screen related variables.
@onready var native_width = DisplayServer.screen_get_size().x
@onready var native_height = DisplayServer.screen_get_size().y
@onready var window = get_window()
@onready var window_mode

# Time variables.
@onready var global_date
@onready var global_time

# Rotation variables.
@onready var hour_degree
@onready var minute_degree
@onready var second_degree

# Graphic quality variables.
@onready var size
@onready var path
@onready var zoom

# Positioning AmPm variables.
@onready var am_pm_x
@onready var am_pm_y
@onready var am_image

# Check the operating system.
@onready var platform = OS.get_name()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Setting up the scaling factor and suitable image based on the screen size.
	if native_width > native_height:
		size = find_size(native_width, native_height)
	else:
		size = find_size(native_height, native_width)
		
	# Load the images.
	base_number.texture = load("res://images/clock/base_number.png")
	hour_needle.texture = load("res://images/clock/hour_needle.png")
	minute_needle.texture = load("res://images/clock/minute_needle.png")
	second_needle.texture = load("res://images/clock/second_needle.png")
	
	# Determine the day and the night.
	am_pm_status()
	
	# Setting up the camera zoom.
	zoom = 1024 / float(size)
	main_camera.zoom = Vector2(zoom, zoom)
	
	# Set window mode for desktop platform.
	if platform == "Windows" || platform == "Linux":
		window.set_mode(0)
		window.size = Vector2(size/2, size/2)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Check the date system in the real time.
	global_date = Time.get_datetime_dict_from_system()	
	global_time = Time.get_time_string_from_system()
	
	# Set the rotation degrees for all the needle using dictionary.
	# Set the base degrees.
	hour_degree = global_date.hour * 30
	minute_degree = global_date.minute * 6
	second_degree = global_date.second * 6
	
	# Set the rotation degrees.
	hour_needle.rotation_degrees = hour_degree + (minute_degree / 12)
	minute_needle.rotation_degrees = minute_degree + (second_degree / 60)
	second_needle.rotation_degrees = second_degree
	
	# Change the day and night status at the exact time using string.
	if global_time == "12:00:00" || global_time == "00:00:00":
		am_pm_status()


	# Called when an input detected.
	if Input.is_action_just_released("exit_button"):
		get_tree().quit()
	
	if platform == "Windows" || platform == "Linux":		
		if Input.is_action_just_released("change_window_mode"):
			change_window_mode()


func change_window_mode():
	
	# Get the window mode information.
	window_mode = window.get_mode()
	# Switch the window mode.
	match (window_mode):
		0: # Switch to fullscreen.
			window.set_mode(3)
			window.size = Vector2(native_width, native_height)
		3: # Switch to windowed.
			window.set_mode(0)
			window.size = Vector2(size/2, size/2)


# find the square size for the image calculation.
func find_size(width, height):
	if width > height:
		return height
	else:
		return width

# Setting up the AmPm node.
func am_pm_status():	
	if Time.get_datetime_dict_from_system().hour >= 12:
		am_pm.texture = load("res://images/description/pm.png")
	else:
		am_pm.texture = load("res://images/description/am.png")
	
	# Setting up the AmPm image and position.
	am_pm_x = (size / 2 ) - (am_pm.texture.get_width())
	am_pm_y = (size / 2) - (am_pm.texture.get_height())
	am_pm.position = Vector2(am_pm_x, am_pm_y)
