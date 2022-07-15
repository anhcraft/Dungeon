extends KinematicBody2D

const jump_time = 600;
const slide_time = 500;

const default_shape = PoolVector2Array([
	Vector2(-21.3333, 36),
	Vector2(13.3333, 36),
	Vector2(8, -21.3333),
	Vector2(-19.3333, -23.3333)
])

const sliding_shape = PoolVector2Array([
	Vector2(-33.3333, 38.6667),
	Vector2(17.3333, 38.6667),
	Vector2(14.6667, 26.6667),
	Vector2(-4, 17.3333),
	Vector2(-0.666667, 2),
	Vector2(-24.6667, -2.66667),
	Vector2(-39.3333, 19.3333)
])

var last_movement = 0;
var tracking_running = false;
var tracking_running_start = 0;
var jumping = false;
var jump_start = 0;
var sliding = false;
var slide_start = 0;
var direction = Vector2.RIGHT;

func _ready():
	$AnimatedSprite.playing = true
	_set_shape(default_shape)

func _set_shape(arr: PoolVector2Array):
	$CollisionShape2D.polygon = arr
	$LightOccluder2D.occluder.polygon = arr
	$HealthBar.relocate()

func _flip_shape():
	if direction.x > 0:
		$CollisionShape2D.scale.x = 1
	else:
		$CollisionShape2D.scale.x = -1
	$LightOccluder2D.scale = $CollisionShape2D.scale
	$HealthBar.relocate()

func _process(delta):
	var b = $"/root/Player".spot_block
	if b != null && b.material == $"/root/Blocks".LAVA:
		$"/root/Player".drain_health(0.5)
	elif $"/root/Player".get_energy_ratio() > 0.75:
		$"/root/Player".revive_health(0.1)

func _physics_process(delta):
	var speed = 200
	var velocity = Vector2()
	var b = $"/root/Player".spot_block
	if b != null:
		var blocks = $"/root/Blocks"
		var m = b.material
		if m == blocks.SAND:
			speed *= 0.8
		elif m == blocks.WATER:
			speed *= 0.4
		elif m == blocks.LAVA:
			speed *= 0.3

		if b.in_cave:
			$"../Ambient".color = Color(0.3, 0.3, 0.3);
			$Flashlight.visible = true;
		else:
			$"../Ambient".color = Color(1.0, 1.0, 1.0);
			$Flashlight.visible = false;

		$AnimatedSprite.material.set_shader_param("in_liquid", b.is_liquid())

	var now = OS.get_ticks_msec()

	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		direction = Vector2.LEFT
		$AnimatedSprite.flip_h = true
		_flip_shape();
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		direction = Vector2.RIGHT
		$AnimatedSprite.flip_h = false
		_flip_shape();
	if Input.is_action_pressed("ui_up"):
		velocity.y = -speed
	if Input.is_action_pressed("ui_down"):
		velocity.y = speed
	if Input.is_action_pressed("player_slide") && !jumping && !sliding && !b.is_liquid() && $"/root/Player".consume_energy(10.0):
		sliding = true
		slide_start = now
		$AnimatedSprite.play("slide")
		_set_shape(sliding_shape)
	if Input.is_action_pressed("ui_select") && !jumping && !sliding && !b.is_liquid() && $"/root/Player".consume_energy(10.0):
		jumping = true
		jump_start = now
		$AnimatedSprite.play("jump")

	if jumping:
		var elapsed = now - jump_start
		var x = elapsed/(jump_time * 0.5) - 1
		velocity.y = speed * x * x * x * 5
		z_index = 1 # avoid collision
		if elapsed > jump_time || b.is_liquid():
			z_index = 0
			jumping = false
			jump_start = now
			$AnimatedSprite.play("default")

	elif sliding:
		var elapsed = now - slide_start
		velocity = speed * direction * 3
		if elapsed > slide_time || b.is_liquid():
			sliding = false
			slide_start = now
			$AnimatedSprite.play("default")
			_set_shape(default_shape)

	else:
		var elapsed = now - last_movement
		if velocity.length() > 0:
			$AnimatedSprite.play("walking");
			if !tracking_running:
				tracking_running = true
				tracking_running_start = now
			elif now - tracking_running_start > 1000 && $"/root/Player".consume_energy(0.3):
				velocity.x = velocity.x * 2;
				velocity.y = velocity.y * 2;
			last_movement = now
		else:
			$AnimatedSprite.play("default");
			tracking_running = false
			$"/root/Player".supply_energy(0.1)

	move_and_slide(velocity, Vector2(0, 0))
	$"/root/Player".position = position
