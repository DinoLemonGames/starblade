extends CharacterBody3D

@export var camera: Node
@export var player: Node
@export var origin: Node

const MAXSPEED = 100
const ACCELERATION = 0.03
const DECELERATION = 0.2
const BOOSTSPEED = 200
var speed_clamp = 70

# This gets set to BOOSTSPEED when you do a roll
var boost = 0.0

# Roll angle - This changes when you want to manually roll your ship
var roll_angle = 0.0
const MAXROLLANGLE = 75.0
const ROLLSPEED = 0.09
# Barrel Rolling or not
var rrolling = false
var lrolling = false
var can_roll = true
const BARRELROLLSPEED = 0.15

# Ship Rotations
# Roll Left & Right
var z_rotation_mod = -1
const ZCLAMP = 90.0
# Left & Right
var y_rotation_mod = 0.75
const YCLAMP = 40.0
# Up & Down
var x_rotation_mod = -1
const XCLAMP = 40.0

var input_vector = Vector3()

func _physics_process(delta):
	# Get Input
	# Limit Length makes it so keyboard and controller inputs are the same
	input_vector  = Input.get_vector("right", "left", "down", "up").limit_length(.75)
	
	velocity.x = clamp(lerp(velocity.x, input_vector.x * (MAXSPEED + boost), ACCELERATION), -speed_clamp, speed_clamp)
	velocity.y = clamp(lerp(velocity.y, input_vector.y * (MAXSPEED + boost), ACCELERATION), -speed_clamp, speed_clamp)
		
	# Rotate the ship
	# Roll Left and Right
	if not rrolling and not lrolling:
		# Manual rolling
		if Input.is_action_pressed("roll_right"):
			roll_angle = lerp(roll_angle, MAXROLLANGLE * Input.get_action_strength("roll_right"), ROLLSPEED)
			z_rotation_mod = -0.2
		if Input.is_action_pressed("roll_left"):
			roll_angle = lerp(roll_angle, -MAXROLLANGLE * Input.get_action_strength("roll_left"), ROLLSPEED)
			z_rotation_mod = -0.2
		# Back to Center
		if not Input.is_action_pressed("roll_left") and not Input.is_action_pressed("roll_right"):
			roll_angle = lerp(float(roll_angle), 0.0, float(ROLLSPEED))
			z_rotation_mod = -1
		
		# Apply the Rolling Left & Right rotation
		origin.rotation_degrees.z = (velocity.x * z_rotation_mod) + roll_angle
		origin.rotation_degrees.z = clamp(origin.rotation_degrees.z, -ZCLAMP, ZCLAMP)
		speed_clamp = 70
	else:
		origin.rotation_degrees.z = (velocity.x * -1) + roll_angle
		speed_clamp = 250
	
	# Up and Down Rotation
	origin.rotation_degrees.x = clamp(velocity.y * x_rotation_mod, -XCLAMP, XCLAMP)
	# Left and Right Rotation
	origin.rotation_degrees.y = clamp(velocity.x * y_rotation_mod, -YCLAMP, YCLAMP)
	
	print(position.z)
	#print("Velocity X: " + str(velocity.x))
	#print("Velocity Y: " + str(velocity.y))
	
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
			
	
	move_and_slide()
	
	# Clamp the player so you can't go off screen
	# Left | Right
	transform.origin.x = clamp(transform.origin.x, -40, 40)
	# Bottom | Top
	transform.origin.y = clamp(transform.origin.y, -24, 23)
	
	# Make the camera follow the ship
	# Left and Right
	camera.position.x = lerp(player.position.x, player.position.x + position.x, 0.75)
	# Up and Down
	camera.position.y = lerp(player.position.y, (player.position.y + position.y)+3, 0.75)
	camera.position.y = clamp(camera.position.y, player.position.y -15, 18)
	
	# Make the camera look at the ship
	# Left and Right
	camera.rotation_degrees.y = ((player.position.x - position.x)/20)+180
	# Up and Down
	camera.rotation_degrees.x = (player.position.y - position.y)/20

func barrel_rroll():
	if rrolling:
		if roll_angle <= 360.0:
			roll_angle = lerp(roll_angle, 380.0, BARRELROLLSPEED)
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
			roll_angle = lerp(roll_angle, -380.0, BARRELROLLSPEED)
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
