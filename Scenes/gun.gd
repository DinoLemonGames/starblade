extends Node3D

var cooldown = 0
const MAXCOOLDOWN = 8

@onready var guns = [$".", $"../Gun2"]
@onready var main = get_tree().current_scene
var Bullet = load("res://Scenes/bullet.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Shooting
	if Input.is_action_pressed("shoot") and cooldown <= 0:
		for i in guns:
			var bullet = Bullet.instantiate()
			main.add_child(bullet)
			bullet.transform = global_transform
			bullet.velocity = bullet.transform.basis.z * 400
			cooldown = MAXCOOLDOWN * delta
		
	# Cooldown
	if cooldown > 0:
		cooldown -= delta
