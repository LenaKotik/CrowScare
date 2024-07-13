extends Area2D

onready var sprite = $Wheat

var eaten = false

func _ready():
	self.connect("body_entered",self,"interact")

func interact(body):
	if body.is_in_group("enemy"):
		body.eat(self)

func reduce():
	sprite.frame += 1
	if sprite.frame == 11:
		eaten = true
