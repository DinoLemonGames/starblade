extends MeshInstance3D

# Speed of the planet's own spin (radians per second)
@export var y_spin_speed = 1.0

@export var rotation_speed = 5.0

func _process(delta):
	
	# Rotate the planet around the sun
	$"..".rotate_y((rotation_speed / 10) * delta)
	
	# Spin the planet on its Y-axis (vertical spin)
	rotate_y((y_spin_speed / 5) * delta)
	
