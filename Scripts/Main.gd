extends Node2D

onready var anim = $CanvasLayer/AnimationPlayer
onready var retryb = $CanvasLayer/ColorRect/Button
onready var lable = $CanvasLayer/ColorRect/Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var generators = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	retryb.connect("pressed",self,"reload")
	for e in get_tree().get_nodes_in_group("enemy"):
		e.connect("game_over",self,"game_over")
	for s in get_tree().get_nodes_in_group("spotlight"):
		s.connect("finished",self,"win")

func reload():
	get_tree().reload_current_scene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func game_over():
	lable.text = "Game Over"
	anim.play("game_over")
func win():
	generators += 1
	if generators >= 4:
		lable.text = "You Won"
		anim.play("game_over")
