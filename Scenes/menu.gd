extends VBoxContainer

const ENGARTH = preload("res://Scenes/Engarth.tscn")

@onready var camera = $"../Camera3D"
@onready var engarth = $"../RedSun/engarth_planet/engarth"

var new_game = false

func _process(delta):
	if new_game:
		camera.position.y = lerp(camera.position.y, engarth.global_position.y, 0.005)
		camera.position.z = lerp(camera.position.z, engarth.global_position.z, 0.005)
		camera.position.x = lerp(camera.position.x, engarth.global_position.x, 0.005)

func _on_new_game_pressed():
	new_game = true
	$NewGameTimer.start()


func _on_quit_pressed():
	get_tree().quit()


func _on_new_game_timer_timeout():
	get_tree().change_scene_to_packed(ENGARTH)
