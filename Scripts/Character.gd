extends KinematicBody2D

signal interact
signal interupt

export var speed : float

onready var light = $Light2D
onready var flashbase = $FlashBase
onready var rays = $FlashBase/Rays.get_children()

var interactable = false setget set_interactable
var interacting = false
var move_strength = 1

func set_interactable(v):
	interactable=v

func _physics_process(_delta):
	# movement
	var velocity = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized() * speed * move_strength
	move_and_slide(velocity);
	
	# light toggle
	if Input.is_action_just_pressed("toggle"):
		light.enabled = not light.enabled
	
	# interupt
	if Input.is_action_just_released("interact") and interacting:
		emit_signal("interupt")
		move_strength = 1
		interacting = false
	
	# interact
	if Input.is_action_just_pressed("interact") and interactable:
		emit_signal("interact")
		move_strength = 0
		#self.interactable = false
		interacting = true
	
	# flashlight aiming
	flashbase.look_at(get_global_mouse_position())
	
	# raycasting
	for r in rays:
		if r.is_colliding():
			var object = r.get_collider()
			if object.is_in_group("enemy"):
				object.seen()

func die():
	queue_free()
