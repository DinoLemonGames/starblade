extends Node3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var path_move_speed = 50
	#print(path_move_speed)
	$Path3D/PathFollow3D.progress += path_move_speed * delta
