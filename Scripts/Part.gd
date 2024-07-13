extends StaticBody2D

export var id = 0

onready var interactableArea = $InteractableArea
onready var interactableLbl = $InteractableLabel
onready var anim = $AnimationPlayer
onready var sprite = $Part

func _ready():
	sprite.texture = GlobalData.part_textures[id]
	interactableArea.connect("body_entered",self,"interact")
	interactableArea.connect("body_exited",self,"uninteract")

func interact(body):
	if body.is_in_group("player"):
		body.connect("interact",self,"pick_up")
		body.interactable = true
		interactableLbl.visible = true

func uninteract(body):
	if body.is_in_group("player"):
		body.disconnect("interact",self,"pick_up")
		body.interactable = false
		interactableLbl.visible = false

func pick_up():
	anim.play("pick_up")
	GlobalData.parts[id] = GlobalData.parts[id]+1
	GlobalData.emit_signal("parts_updated")

func finished():
	queue_free()
