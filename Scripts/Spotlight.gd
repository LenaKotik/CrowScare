extends StaticBody2D

export var fixTime : float

onready var interactField = $InteractField
onready var fixProgress = $CanvasLayer/ProgressBar
onready var fixTimer = $CanvasLayer/ProgressBar/Timer
onready var interactableLbl = $InteractableLabel
onready var anim = $AnimationPlayer
onready var lightArea = $LightArea

# Called when the node enters the scene tree for the first time.
func _ready():
	interactField.connect("body_entered",self,"interact")
	interactField.connect("body_exited",self,"uninteract")
	fixTimer.connect("timeout",self,"fixUpdate")
	#lightArea.connect("body_entered",self,"seen")

func _physics_process(_delta):
	if not lightArea.monitoring:
		return
	for b in lightArea.get_overlapping_bodies():
		if b.is_in_group("enemy"):
			b.seen()

#func seen(body):
	#if body.is_in_group("enemy"):
		#body.seen()

func interact(body):
	if body.is_in_group("player"):
		body.connect("interact",self,"fix")
		body.connect("interupt",self,"interupt")
		body.interactable = true
		interactableLbl.visible = true

func uninteract(body):
	if body.is_in_group("player"):
		body.interactable = false
		interactableLbl.visible = false
		fixProgress.hide()

func fix():
	fixProgress.show()
	fixTimer.start(fixTime*fixProgress.step/100)
	#interactableLbl.visible = false

func fixUpdate():
	fixProgress.value += fixProgress.step
	if fixProgress.value == fixProgress.max_value:
		interupt()
		fixProgress.hide()
		interactableLbl.hide()
		anim.play("fixed")

func interupt():
	#fixProgress.hide()
	fixTimer.stop()
