extends StaticBody2D

export var fixTime : float

onready var interactField = $InteractField
onready var fixProgress = $CanvasLayer/ProgressBar
onready var fixTimer = $CanvasLayer/ProgressBar/Timer
onready var interactableLbl = $InteractableLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	interactField.connect("body_entered",self,"interact")
	interactField.connect("body_exited",self,"uninteract")
	fixTimer.connect("timeout",self,"fixUpdate")

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

func fix():
	fixProgress.show()
	fixTimer.start(fixTime*fixProgress.step/100)
	interactableLbl.visible = false

func fixUpdate():
	fixProgress.value += fixProgress.step
	if fixProgress.value == fixProgress.max_value:
		interupt()

func interupt():
	fixProgress.hide()
	fixTimer.stop()
