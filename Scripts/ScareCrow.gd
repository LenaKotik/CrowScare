extends KinematicBody2D

export var speed : float
export var rage_strength : float
export var rage_time : float

onready var seenTimer = $SeenTimer
onready var rageTimer = $RageTimer
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var nav = get_tree().get_nodes_in_group("navigation")[0]
onready var vis = $VisibilityNotifier2D

var move_strength = 1;
var rage = 0

func _ready():
	seenTimer.connect("timeout",self,"unseen")
	rageTimer.connect("timeout",self,"unrage")
	vis.connect("screen_exited",self,"unseen")

func seen():
	seenTimer.start()
	move_strength = 0;
	rage += 1
	print(rage)

func unseen():
	rageTimer.start(rage_time)
	move_strength = rage_strength;

func unrage():
	rage = 0

func _physics_process(delta):
	var path = nav.get_simple_path(global_position,player.global_position)
	var velocity = Vector2.ZERO
	if not path.empty():
		$Line2D.global_position = Vector2.ZERO
		$Line2D.points = path
		if not rageTimer.is_stopped() and move_strength > 0:
			move_strength = lerp(1,rage_strength,rageTimer.time_left/rage_time)
		velocity = (path[1] - global_position).normalized() * speed * move_strength
	
	move_and_slide(velocity)
