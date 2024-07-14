extends KinematicBody2D

signal game_over

export var speed : float
export var rage_strength : float
export var rage_time : float
export var agroDecay : float

onready var seenTimer = $SeenTimer
onready var rageTimer = $RageTimer
onready var eatTimer = $EatTimer
onready var scramTimer = $ScramTimer
onready var player = get_tree().get_nodes_in_group("player")[0]
onready var nav = get_tree().get_nodes_in_group("navigation")[0]
onready var vis = $VisibilityNotifier2D
onready var hurtbox = $Hurtbox
onready var walkSnd = $WalkSound
onready var eatSnd = $EatSound
onready var huntSnd = $HuntSound

var move_strength = 1;
var rage = 0
var hunting = false
var eating = false
var scram = false
var target = null
var agro = 0

func _ready():
	seenTimer.connect("timeout",self,"unseen")
	rageTimer.connect("timeout",self,"unrage")
	scramTimer.connect("timeout",self,"unscram")
	vis.connect("screen_exited",self,"unseen")
	hurtbox.connect("body_entered",self,"hurtbox_collision")

func seen():
	target = null
	eating = false
	scram = true
	eatSnd.stop()
	eatTimer.stop()
	seenTimer.start()
	move_strength = 0;
	rage += 0.01

func unseen():
	rageTimer.start(rage_time)
	scramTimer.start()
	move_strength = min(sqrt(rage)/2+1,3);

func unrage():
	agro += 2+rage*2
	agro = agro
	rage = 0

func hurtbox_collision(body):
	if move_strength > 0 and body.is_in_group("player"):
		body.die()
		walkSnd.stop()
		emit_signal("game_over")

func decide():
	if move_strength > 0 and ((randi()%100)<=(int(agro)+5)):
		hunting = true
		huntSnd.play()
	if hunting:
		return player
	if scram:
		var spotlights = get_tree().get_nodes_in_group("spotlight")
		spotlights.shuffle()
		for s in spotlights:
			if global_position.distance_squared_to(s.global_position) < player.global_position.distance_squared_to(s.global_position):
				return s
		return spotlights[0]
	var stalks = get_tree().get_nodes_in_group("stalks")
	stalks.shuffle()
	for s in stalks:
		if not s.eaten:
			return s
	emit_signal("game_over")
	return player

func _physics_process(delta):
	if not is_instance_valid(player) or eating: return
	agro = lerp(agro,agro/2,agroDecay)
	if hunting:
		agro = lerp(agro,0,agroDecay*10)
		agro -= agroDecay*10
		if agro <= 0:
			hunting = false
			target = null
	if target == null:
		target = decide()
	var path = nav.get_simple_path(global_position,target.global_position)
	var velocity = Vector2.ZERO
	if not path.empty():
		$Line2D.global_position = Vector2.ZERO
		$Line2D.points = path
		if not rageTimer.is_stopped() and move_strength > 0:
			move_strength = lerp(1,min(sqrt(rage)/2+1,3),rageTimer.time_left/rage_time)
		velocity = (path[1] - global_position).normalized() * speed * move_strength
	if walkSnd.playing and velocity == Vector2.ZERO:
		walkSnd.stop()
	elif not walkSnd.playing and velocity != Vector2.ZERO:
		walkSnd.play()
	move_and_slide(velocity)

func eat(stalk):
	walkSnd.stop()
	if not eatSnd.playing:
		eatSnd.play()
	target = null
	eating = true
	eatTimer.start()
	yield(eatTimer, "timeout")
	stalk.reduce()
	if stalk.eaten:
		eating = false
		eatSnd.stop()
	else:
		eat(stalk) # scary

func unscram():
	scram = false
	target = null
