extends KinematicBody2D

var squared_distance_follow = pow(300, 2)
var squared_distance_attack = pow(70, 2)
var speed = 3
var size = 5

var sleep_start_time = 0
var attack_start_time = 0
var awake = true

var max_health = 100.0
var _health = 100.0

func set_health(v: float):
	_health = min(v, max_health)

func drain_health(d: float):
	var remain = _health - d
	if remain >= 0:
		_health = remain
	return remain >= 0

func revive_health(d: float):
	var comming = _health + d
	if comming <= max_health:
		_health = comming
	return comming <= max_health

func get_health():
	return _health

func get_health_ratio():
	return _health/max_health

func on_attack():
	var s_dist = position.distance_squared_to($"/root/Player".position)
	if !awake && s_dist < squared_distance_attack:
		awake = true

func _ready():
	$AnimatedSprite.play()

func _process(delta):
	$HealthBar.set_target_ratio(get_health_ratio())

	var s_dist = position.distance_squared_to($"/root/Player".position)
	if awake && s_dist < squared_distance_follow:
		var dir = position.direction_to($"/root/Player".position)
		move_and_collide(dir * speed)

	var now = OS.get_ticks_msec()
	if awake && s_dist < squared_distance_attack:
		attack_start_time = now
		$AnimatedSprite.play("attack")
		$"/root/Player".drain_health(0.5)

func _on_AnimatedSprite_animation_finished():
	var now = OS.get_ticks_msec()
	if $AnimatedSprite.animation == "attack" && now - attack_start_time > 3000:
		$AnimatedSprite.play("default")
	elif ($AnimatedSprite.animation == "default" || $AnimatedSprite.animation == "jump"):
		var v = randf()
		if v < 0.2:
			awake = false
			$AnimatedSprite.play("sleep")
			sleep_start_time = now
		elif v < 0.4:
			$AnimatedSprite.play("jump")
	elif $AnimatedSprite.animation == "sleep" && now - sleep_start_time > 30000:
		$AnimatedSprite.play("default")
		awake = true
