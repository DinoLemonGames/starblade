extends CharacterBody3D

@export var camera: Node
@export var player: Node
@export var origin: Node

const MAXSPEED = 50
const ACCELERATION = 1
const BOOSTSPEED = 25

# This gets set to BOOSTSPEED when you hit boost button
var boost = 0

# Roll angle - This changes when you want to manually roll your ship
var roll_angle = 0.0
const MAXROLLANGLE = 85.0
const ROLLSPEED = 0.09

var input_vector = Vector3()

func _physics_process(delta):
	# Get Input
	# Limit Length makes it so keyboard and controller inputs are the same
	input_vector  = Input.get_vector("right", "left", "down", "up").limit_length(.75)
	
	# Set the velocity
	velocity.x = move_toward(velocity.x, input_vector.x * (MAXSPEED + boost), ACCELERATION)
	velocity.y = move_toward(velocity.y, input_vector.y * (MAXSPEED + boost), ACCELERATION)
	
	# Rotate the ship
	# Roll Left and Right
	origin.rotation_degrees.z = clamp((velocity.x * -1.5) + roll_angle, -MAXROLLANGLE, MAXROLLANGLE)
	
	if Input.is_action_pressed("roll_right"):
		roll_angle = lerp(roll_angle, MAXROLLANGLE * Input.get_action_strength("roll_right"), ROLLSPEED)
	if Input.is_action_pressed("roll_left"):
		roll_angle = lerp(roll_angle, -MAXROLLANGLE * Input.get_action_strength("roll_left"), ROLLSPEED)
	if not Input.is_action_pressed("roll_left") and not Input.is_action_pressed("roll_right"):
		roll_angle = lerp(roll_angle, 0.0, ROLLSPEED)
	print(Input.get_action_strength("roll_right"))
	# Up and Down
	origin.rotation_degrees.x = velocity.y * -1
	# Left and Right
	origin.rotation_degrees.y = velocity.x * 1.5
	
	# Boosting
	if Input.is_action_just_pressed("boost"):
		boost = BOOSTSPEED
		$Timer.start()
	
	move_and_slide()
	
	# Clamp the player so you can't go off screen
	transform.origin.x = clamp(transform.origin.x, -30, 30)
	transform.origin.y = clamp(transform.origin.y, -22, 21)
	
	# Make the camera follow the ship
	# Left and Right
	camera.position.x = lerp(player.position.x, player.position.x + position.x, 0.75)
	# Up and Down
	camera.position.y = lerp(player.position.y, (player.position.y + position.y)+3, 0.9)
	camera.position.y = clamp(camera.position.y, player.position.y -15, 18)
	
	# Make the camera look at the ship
	var cam_move_speed = 0.1
	var right_clamp = 175
	var left_clamp = 200
	var bottom_clamp = 13
	var top_clamp = -6
	# Left and Right
	#camera.rotation_degrees.y = clamp((player.position.x - position.x/4)+180, right_clamp, left_clamp)
	camera.rotation_degrees.y = ((player.position.x - position.x)/4)+180
	# Up and Down
	#camera.rotation_degrees.x = clamp((player.position.y - position.y/4), top_clamp, bottom_clamp)
	camera.rotation_degrees.x = (player.position.y - position.y)/4
	# Roll Left and Right
	#camera.rotation_degrees.z = rotation_degrees.z / -5
	
	#camera.position.x = clamp(camera.position.x, player.position.x - 4, player.position.x + 4)
	#camera.position.y = clamp(camera.position.y, player.position.y - 2, player.position.y + 2)


func _on_timer_timeout():
	boost = 0
