extends Node

# Setting up the variables
# Analog node variables.
@onready var clock_face = $Analog/ClockFace
@onready var needle_hour = $Analog/NeedleHour
@onready var needle_minute = $Analog/NeedleMinute
@onready var needle_second = $Analog/NeedleSecond
@onready var period = $Analog/Period
@onready var view_main = $ViewMain
@onready var sound_effect_01 = $SoundEffect01
@onready var sound_effect_02 = $SoundEffect02

# Screen related variables.
@onready var native_width = DisplayServer.screen_get_size().x
@onready var native_height = DisplayServer.screen_get_size().y
@onready var window = get_window()
@onready var window_mode
@onready var dark_mode = false

# Time variables.
@onready var global_date
@onready var global_time

# Rotation variables.
@onready var degree_hour
@onready var degree_minute
@onready var degree_second

# Display detection.
@onready var display_size

# Check the operating system.
@onready var platform = OS.get_name()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	# Setting up the scaling factor for window mode.
	if native_width > native_height:
		display_size = native_height
	else:
		display_size = native_width
		
	# Load the images.
	clock_face.texture = load("res://images/clock/wektu_clock_black_face_default.png")
	needle_hour.texture = load("res://images/clock/wektu_needle_black_hour_default.png")
	needle_minute.texture = load("res://images/clock/wektu_needle_black_minute_default.png")
	needle_second.texture = load("res://images/clock/wektu_needle_black_second_default.png")
	
	# Determine the day and the night.
	period_status()
	
	# Set window mode for desktop platform.
	if platform == "Windows" || platform == "Linux":
		window.set_mode(0)
		window.size = Vector2(display_size/2, display_size/2)
	
	print(RenderingServer.get_default_clear_color())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Check the date system in the real time.
	global_date = Time.get_datetime_dict_from_system()	
	global_time = Time.get_time_string_from_system()
	
	# Set the rotation degrees for all the needle using dictionary.
	# Set the base degrees.
	degree_hour = global_date.hour * 30
	degree_minute = global_date.minute * 6
	degree_second = global_date.second * 6
	
	# Set the rotation degrees.
	needle_hour.rotation_degrees = degree_hour + (degree_minute / 12)
	needle_minute.rotation_degrees = degree_minute + (degree_second / 60)
	needle_second.rotation_degrees = degree_second
	
	# Change the day and night status at the exact time using string.
	if global_time == "12:00:00" || global_time == "00:00:00":
		period_status()

	# Called when an input detected.
	if Input.is_action_just_released("exit_button"):		
		get_tree().quit()
		
	if Input.is_action_just_released("dark_mode_button"):
		sound_effect_01.play()
		switch_dark_mode()		
				
	if platform == "Windows" || platform == "Linux":				
		if Input.is_action_just_released("window_mode_button"):		
			sound_effect_02.play()
			switch_window_mode()

# Switch function for the window mode.
func switch_window_mode():
	
	# Get the window mode information.
	window_mode = window.get_mode()
	# Switch the window mode.
	match (window_mode):
		0: # Switch to fullscreen.
			window.set_mode(3)
			window.size = Vector2(native_width, native_height)
		3: # Switch to windowed.
			window.set_mode(0)
			window.size = Vector2(display_size/2, display_size/2)
			
# Switch to dark mode and vice versa. 			
func switch_dark_mode():		
	match dark_mode:
		true:
			clock_face.texture = load("res://images/clock/wektu_clock_black_face_default.png")
			needle_hour.texture = load("res://images/clock/wektu_needle_black_hour_default.png")
			needle_minute.texture = load("res://images/clock/wektu_needle_black_minute_default.png")
			needle_second.texture = load("res://images/clock/wektu_needle_black_second_default.png")
			dark_mode = false
			RenderingServer.set_default_clear_color(Color(1.0, 1.0, 1.0, 1.0))
		false:
			clock_face.texture = load("res://images/clock/wektu_clock_white_face_default.png")
			needle_hour.texture = load("res://images/clock/wektu_needle_white_hour_default.png")
			needle_minute.texture = load("res://images/clock/wektu_needle_white_minute_default.png")
			needle_second.texture = load("res://images/clock/wektu_needle_white_second_default.png")
			dark_mode = true
			RenderingServer.set_default_clear_color(Color(0.0, 0.0, 0.0, 1.0))		
	period_status()

# Setting up the Period image and position.
func period_status():	
	if Time.get_datetime_dict_from_system().hour >= 12:
		match dark_mode:
			true:
				period.texture = load("res://images/period/wektu_period_white_pm_default.png")
			false:
				period.texture = load("res://images/period/wektu_period_black_pm_default.png")
	else:
		match dark_mode:
			true:
				period.texture = load("res://images/period/wektu_period_white_am_default.png")
			false:
				period.texture = load("res://images/period/wektu_period_black_am_default.png")
	
	period.position = Vector2(512 - period.texture.get_width(), 512 - period.texture.get_height())
