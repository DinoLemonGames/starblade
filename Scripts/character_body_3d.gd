extends CharacterBody3D

@export var camera: Node
@export var player: Node
@export var origin: Node

const MAXSPEED = 50.0
const ACCELERATION = 1.0
const BOOSTSPEED = 125.5

# This gets set to BOOSTSPEED when you hit boost button
var boost = 0.0

# Roll angle - This changes when you want to manually roll your ship
var roll_angle = 0.0
const MAXROLLANGLE = 85.0
const ROLLSPEED = 0.09
# Barrel Rolling or not
var rrolling = false
var lrolling = false
var can_roll = true

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
	origin.rotation_degrees.z = (velocity.x * -1.5) + roll_angle
	if not rrolling and not lrolling:
		# Manual rolling
		if Input.is_action_pressed("roll_right"):
			roll_angle = lerp(roll_angle, MAXROLLANGLE * Input.get_action_strength("roll_right"), ROLLSPEED)
		if Input.is_action_pressed("roll_left"):
			roll_angle = lerp(roll_angle, -MAXROLLANGLE * Input.get_action_strength("roll_left"), ROLLSPEED)
		# Back to Center
		if not Input.is_action_pressed("roll_left") and not Input.is_action_pressed("roll_right"):
			roll_angle = lerp(float(roll_angle), 0.0, float(ROLLSPEED))
	
	print(origin.rotation_degrees.z)
	
	# Barrel Roll RIGHT
	if Input.is_action_just_pressed("roll_right"):
		if $BarrelRollTimer.is_stopped():
			$BarrelRollTimer.start()
		else:
			if Input.is_action_just_pressed("roll_right"):
				$BarrelRollTimer.stop()
				if can_roll and not lrolling:
					rrolling = true
	if rrolling:
		barrel_rroll()
	# Barrel Roll LEFT
	if Input.is_action_just_pressed("roll_left"):
		if $BarrelRollTimer.is_stopped():
			$BarrelRollTimer.start()
		else:
			if Input.is_action_just_pressed("roll_left"):
				$BarrelRollTimer.stop()
				if can_roll and not rrolling:
					lrolling = true
	if lrolling:
		barrel_lroll()
			
	
	# Up and Down Rotation
	origin.rotation_degrees.x = velocity.y * -1
	# Left and Right Rotation
	origin.rotation_degrees.y = velocity.x * 1.5
	
	# Boosting
	if Input.is_action_just_pressed("boost"):
		print("BOOST")
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
	camera.rotation_degrees.y = ((player.position.x - position.x)/4)+180
	# Up and Down
	camera.rotation_degrees.x = (player.position.y - position.y)/4

func _on_timer_timeout():
	boost = 0.0

func barrel_rroll():
	if rrolling:
		if roll_angle <= 360.0:
			roll_angle = lerp(roll_angle, 380.0, 0.1)
			boost = BOOSTSPEED
		else:
			roll_angle = 0.0
			boost = 0.0
			can_roll = false
			$RollCooldownTimer.start()
			rrolling = false

func barrel_lroll():
	if lrolling:
		if roll_angle >= -360.0:
			roll_angle = lerp(roll_angle, -380.0, 0.1)
			boost = BOOSTSPEED
		else:
			roll_angle = 0.0
			boost = 0.0
			can_roll = false
			$RollCooldownTimer.start()
			lrolling = false


func _on_roll_cooldown_timer_timeout():
	can_roll = true
	$"CollisionShape/ShipOrigin/EX-213/OmniLight3D".light_energy = 10
	$RollRechargedFlashTimer.start()


func _on_roll_recharged_flash_timer_timeout():
	$"CollisionShape/ShipOrigin/EX-213/OmniLight3D".light_energy = 0
