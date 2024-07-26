extends CharacterBody3D

const ACCEL = 10
const DEACCEL = 30

const SPEED = 5.0
const SPRINT_MULT = 2
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.06
@onready var Game_over :Control = get_node("../Control")
@onready var Game_over_timer :Timer = get_node("../Game_over_timer")
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var camera
var rotation_helper
var dir = Vector3.ZERO
var flashlight
signal remove_mouse
signal snakes_go
# esnanremente data   hi
var ensnared = false
var ensnared_position:Vector3 
var snakes_around_you :int = 0 
# for seeding the sine wave for heavier ensarement snap back
var time = 1.1
var timer_oneshot :bool = true

func _ready():
	camera = $rotation_helper/Camera3D
	rotation_helper = $rotation_helper
	
	setup_level()
	
	remake_connections()
	#DOES NOT WORK AND NEEDS TO BE MOVED#
	if GlobalVars.game_started == true:
		emit_signal("remove_mouse")
		print("should be removing the enable mouse button AAAAAAAAsDDD")
		emit_signal("snakes_go")
		
		
	
func _input(event):
	# This section controls your player camera. Sensitivity can be changed.
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation
		camera_rot.x = clampf(camera_rot.x, -1.4, 1.4)
		rotation_helper.rotation = camera_rot


func _physics_process(delta):
	var moving = false
	# Add the gravity. Pulls value from project settings.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and (snakes_around_you < 2):
		velocity.y = JUMP_VELOCITY
	
	# This just controls acceleration. Don't touch it.
	var accel
	if dir.dot(velocity) > 0:
		accel = ACCEL
		moving = true
	else:
		accel = DEACCEL
		moving = false

	if snakes_around_you == 2:
		if timer_oneshot:
			Game_over_timer.start()
			timer_oneshot = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with a custom keymap depending on your control scheme. These strings default to the arrow keys layout.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * accel * delta
	if Input.is_key_pressed(KEY_SHIFT):
		direction = direction * SPRINT_MULT
	else:
		pass

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	if ensnared:
		time+= delta
		slow_move_back(ensnared_position,delta,wave(1,3,time,delta)+8.0)
		
		if ((ensnared_position-self.get_global_position()).length() > .58):
			snakes_around_you = 0 
			ensnared = false
			

func _on_button_button_down():

	
	emit_signal("remove_mouse")
	GlobalVars.game_started = true

func _on_snake_ensnared():
	ensnared = true
	ensnared_position = self.get_global_position() # may want a different position , 
	snakes_around_you += 1

func slow_move_back(pos:Vector3, delta:float, move_strength:float):
	var current_position = self.get_global_position() # get the position 
	self.position = self.position.lerp(pos, delta * move_strength)
	
	

func wave(amplitude:float, freq:int, time:float, delta):
		
		freq = 1
		amplitude = .1
		var variation 
		variation = sin(time * freq) * amplitude
		return variation

# this is a test if you can commit 


func _on_game_over_timer_timeout():
	print("ten seconds up ")
	Game_over.visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_button_pressed():
	get_tree().reload_current_scene()
	
	
func remake_connections():
	
	var all_snakes :Array = get_tree().get_nodes_in_group("snake")
	
	var frame_rate_manager :Node3D = get_node("..")

	
	var timer_handle :Timer = get_node("../Game_over_timer")
	var game_over_button_handle :Button = get_node("../Control/Button")
	var callable_mouse_button = Callable(self,"_on_button_button_down")
	var callable_ensnare = Callable(self, "_on_snake_ensnared")
	var timer_callable = Callable(self, "_on_game_over_timer_timeout")
	var reset_level = Callable(self,"_on_button_pressed")
	for n in range(all_snakes.size()):
		all_snakes[n].connect("ensnared",callable_ensnare)
	timer_handle.connect("timeout",timer_callable)
	game_over_button_handle.connect("pressed",reset_level)
	


func _on_camper_area_reconnect_snakes() -> void:
	print("pleace reconenct everything")
	remake_connections()


func _on_node_3d_reconnect_snakes() -> void:
	print("pleace reconenct everything")
	remake_connections()
	
	
func setup_level():
	print("please remove mouse")
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
