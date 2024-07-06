extends KinematicBody2D

export var speed : float

onready var light = $Light2D
onready var flashbase = $FlashBase
onready var rays = $FlashBase/Rays.get_children()

func _physics_process(_delta):
	# movement
	var velocity = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized() * speed
	move_and_slide(velocity);
	
	# light toggle
	if Input.is_action_just_pressed("toggle"):
		light.enabled = not light.enabled
	
	# flashlight aiming
	flashbase.look_at(get_global_mouse_position())
	
	# raycasting
	for r in rays:
		if r.is_colliding():
			var object = r.get_collider()
			if object.is_in_group("enemy"):
				object.seen()
