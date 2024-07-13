extends StaticBody2D

export var fixTime : float

onready var interactField = $InteractField
onready var fixProgress = $CanvasLayer/ProgressBar
onready var fixTimer = $CanvasLayer/ProgressBar/Timer
onready var interactableLbl = $InteractableLabel
onready var anim = $AnimationPlayer
onready var lightArea = $LightArea
onready var partsPanel = $Panel
onready var textureContainer = $Panel/HBoxContainer

var fixable = false
var part_ids = []

# Called when the node enters the scene tree for the first time.
func _ready():
	interactField.connect("body_entered",self,"interact")
	interactField.connect("body_exited",self,"uninteract")
	fixTimer.connect("timeout",self,"fixUpdate")
	#lightArea.connect("body_entered",self,"seen")
	randomize()
	part_ids = GlobalData.generate_pattern(3)
	parts_ui_update()
	GlobalData.connect("parts_updated",self,"parts_ui_update")

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
		body.disconnect("interact",self,"fix")
		body.disconnect("interupt",self,"interupt")
		body.interactable = false
		interactableLbl.visible = false
		fixProgress.hide()
		partsPanel.hide()

func fix():
	if not fixable:
		if partsPanel.visible and sufficent_parts():
			for p in part_ids:
				GlobalData.parts[p] = GlobalData.parts[p] - 1
			GlobalData.emit_signal("parts_updated")
			fixable = true
			partsPanel.hide()
		else:
			partsPanel.show()
	else:
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

func parts_ui_update():
	var rects = textureContainer.get_children() 
	for i in range(len(rects)):
		rects[i].texture = GlobalData.part_textures[part_ids[i]]
		rects[i].get_node("Label").text = "%d/1" % GlobalData.parts[part_ids[i]]

func sufficent_parts() -> bool:
	var parts_copy = GlobalData.parts.duplicate()
	for p in part_ids:
		parts_copy[p] -= 1
		if parts_copy[p] < 0:
			return false
	return true
