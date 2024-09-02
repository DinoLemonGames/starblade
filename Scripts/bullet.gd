extends CharacterBody3D

func _physics_process(delta):
	move_and_slide()

func _on_timer_timeout():
	queue_free()
