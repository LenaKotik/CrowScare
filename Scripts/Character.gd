extends KinematicBody2D

signal interact
signal interupt

export var speed : float

onready var light = $Light2D
onready var flashbase = $FlashBase
onready var rays = $FlashBase/RayBase/Rays.get_children()
onready var sprite = $Icon
onready var sprite_arm = $FlashBase/Sprite
onready var rayBase = $FlashBase/RayBase

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
	
	if velocity.length() > 0:
		sprite.playing = true
	else:
		sprite.playing = false
		sprite.frame = 0
	
	sprite.flip_h = (get_global_mouse_position()-global_position).x > 0
	sprite.offset.x = 15 if sprite.flip_h else -15
	sprite_arm.flip_v = not sprite.flip_h
	sprite_arm.offset.y = 26 if sprite_arm.flip_v else -26
	rayBase.position.y = -11 if sprite_arm.flip_v else 11
	
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
