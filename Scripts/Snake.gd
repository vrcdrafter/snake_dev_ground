extends Node3D

#Target to be tracked
@export var target : Node3D
#How much (in meters) path is expanded each time when needed
@export var path_update_len : float = 2.0
#Max speed of snake
@export var max_speed : float = 0.0
#Acceleration of snake
@export var acceleration : float = .5
#Higher values makes path corners more curved
@export var path_smoothing : float = 0.2

@onready var path_node : Path3D = $SnakePath
@onready var movement_path : Curve3D = $SnakePath.curve
@onready var path_follow : SkeletonPathFollow3D = $SnakePath/SkeletonPathFollow3D
@onready var nav_agent : NavigationAgent3D = $SnakePath/SkeletonPathFollow3D/steve/NavAgent

var _nav_map : RID
@export var _ensnared : bool = false
signal ensnared 

var snake_state:String = "player_seeking"
# these are all of the object that I want the snakes to idly move to .
var patrol_objects :Array = []
var pick_new_object :bool = false

#Class for easier storage and update of curve points
class CurvePoint:
	var point : Vector3
	var point_in : Vector3
	var point_out : Vector3
	
	func trans(transf : Transform3D):
		point_in = point + point_in
		point_out = point + point_out
		point = transf * point
		point_in = transf * point_in
		point_out = transf * point_out
	
	func loc(node : Node3D):
		point = node.to_local(point)
		point_in = node.to_local(point_in) - point
		point_out = node.to_local(point_out) - point

func _ready():
	_nav_map = get_world_3d().get_navigation_map()
	nav_agent.max_speed = max_speed
	
	for child in get_node("../idle_objects").get_children():
		patrol_objects.append(child)
	# for getting the speed up on the snakes
	var start_button :Button = get_node("../Button")
	var callable = Callable(self,"give_snake_speed")
	start_button.connect("button_down",callable)
	# connecting another signal for player 
	if GlobalVars.game_started == true:
		give_snake_speed()


func _physics_process(delta : float):

	if snake_state == "player_seeking":
		target = get_node("../Player")
		
	if snake_state == "patrol":
		# logic to pick new cub if close enough  .
		if ((target.global_position - path_follow.global_position).length() < 3.0):
			pick_new_object = true
		if pick_new_object: 
			# to make sure the next target is different 
			var next_target = patrol_objects.pick_random()
			while next_target == target:
				next_target = patrol_objects.pick_random()
			target = next_target
			pick_new_object = false
	#Vector3.RIGHT because that's way snake is facing
	var targetVel : Vector3 = Vector3.RIGHT * max_speed
	nav_agent.velocity = nav_agent.velocity.move_toward(targetVel, delta * acceleration)
	#nav_agent.get_next_path_position()
	path_follow.progress += nav_agent.velocity.length() * delta
	if(!_ensnared && movement_path.get_baked_length() - path_follow.progress < path_update_len):
		_append_path()
	if((get_node("../Player").global_position - path_follow.global_position).length() < path_update_len * 1 && !_ensnared):
		# if it reaches a cube go pick another one
		
		_ensnare_target()
		_ensnared = true
		
		emit_signal("ensnared")
	# check for snake if missed target and need to continue pursuit , IGNORE IF CUBE
	if (_ensnared and ((target.global_position - path_follow.global_position).length() > 4.0) and ((target.global_position - path_follow.global_position).length() < 16.0)):
		_ensnared = false
	# condition to go into patrol mode if too far away from player
	if !_ensnared and ((get_node("../Player").global_position - path_follow.global_position).length() > 16.0) and not (snake_state == "patrol"):
		snake_state = "patrol"
		
		pick_new_object = true
		# condition to go into seek player mode 
	if ((get_node("../Player").global_position - path_follow.global_position).length() < 14) :
		snake_state = "player_seeking"
		
		# condition to seek new patrol target
	
	

#Called to prepare next part of path toward target
func _append_path():
	var lastPathPos : Vector3 = path_node.to_global(movement_path.get_point_position(movement_path.point_count - 1))
	var currentPos : Vector3 = NavigationServer3D.map_get_closest_point(_nav_map, lastPathPos)
	var targetPos : Vector3 = NavigationServer3D.map_get_closest_point(_nav_map, target.global_position)
	var navPath : PackedVector3Array = NavigationServer3D.map_get_path(_nav_map, currentPos, targetPos, true)
	if(navPath.size() < 2):
		return
	var currentPoint : int = 1
	var lastPos : Vector3 = currentPos
	#lastPos.y = 0.0
	var lenLeft : float = path_update_len
	while(lenLeft > 0.0 && currentPoint < navPath.size()):
		var currentPointPos : Vector3 = navPath[currentPoint]
		#currentPointPos.y = 0.0
		var clen : float = (currentPointPos - lastPos).length()
		if(clen > lenLeft):
			#Too far away
			var newPoint : Vector3 = lastPos + (currentPointPos - lastPos).normalized() * lenLeft
			movement_path.add_point(path_node.to_local(newPoint))
			lenLeft = 0.0
		else:
			#Too close
			movement_path.add_point(path_node.to_local(currentPointPos))
			lenLeft -= clen
		_smooth_point(path_smoothing)
		lastPos = currentPointPos
		currentPoint += 1

func _smooth_point(smooth_force : float):
	var prevPos : Vector3 = movement_path.get_point_position(movement_path.point_count - 3)
	var nextPos : Vector3 = movement_path.get_point_position(movement_path.point_count - 1)
	#Just in case
	#prevPos.y = 0
	#nextPos.y = 0
	var handle : Vector3 = (nextPos - prevPos).normalized() * smooth_force
	movement_path.set_point_out(movement_path.point_count - 2, handle)
	movement_path.set_point_in(movement_path.point_count - 2, -handle)

func _ensnare_target():
	var targetTransform : Transform3D = target.global_transform
	targetTransform = targetTransform.looking_at(path_follow.global_position)
	var ensData : Curve3D = preload("res://Resources/EnsnarmentData.res")
	#Append to movement path
	for i in ensData.point_count:
		var cp : CurvePoint = CurvePoint.new()
		cp.point = ensData.get_point_position(i)
		cp.point_in = ensData.get_point_in(i)
		cp.point_out = ensData.get_point_out(i)
		cp.trans(targetTransform)
		cp.loc(path_node)
		movement_path.add_point(cp.point, cp.point_in, cp.point_out)

#Avoidance is not working anyway...
func _on_nav_agent_velocity_computed(safe_velocity : Vector3):
	#nav_agent.velocity = safe_velocity
	pass
func give_snake_speed():
	max_speed = 3
