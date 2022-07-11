extends KinematicBody2D

var last_movement = 0;
var tracking_running = false;
var tracking_running_start = 0;

func _physics_process(delta):
	var speed = 300
	var velocity = Vector2()

	if $"/root/Player".spot_block != null:
		var blocks = $"/root/Blocks"
		var m = $"/root/Player".spot_block.material
		$AnimatedSprite.material.set_shader_param("in_liquid", false)
		if m == blocks.SAND:
			speed *= 0.8
		elif m == blocks.WATER:
			speed *= 0.4
			$AnimatedSprite.material.set_shader_param("in_liquid", true)
		elif m == blocks.LAVA:
			speed *= 0.3
			$AnimatedSprite.material.set_shader_param("in_liquid", true)

		if $"/root/Player".spot_block.in_cave:
			$"../Ambient".color = Color(0.3, 0.3, 0.3);
			$Flashlight.visible = true;
		else:
			$"../Ambient".color = Color(1.0, 1.0, 1.0);
			$Flashlight.visible = false;

	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		$AnimatedSprite.flip_h = true
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		$AnimatedSprite.flip_h = false
	if Input.is_action_pressed("ui_up"):
		velocity.y = -speed
	if Input.is_action_pressed("ui_down"):
		velocity.y = speed

	var now = OS.get_ticks_msec()
	var elapsed = now - last_movement
	if velocity.length() > 0:
		$AnimatedSprite.play("walking");
		if !tracking_running:
			tracking_running = true
			tracking_running_start = now
		elif now - tracking_running_start > 1000:
			velocity.x = velocity.x * 1.5;
			velocity.y = velocity.y * 1.5;
		last_movement = now
	else:
		$AnimatedSprite.play("default");
		tracking_running = false

	move_and_slide(velocity, Vector2(0, 0))
	$"/root/Player".position = position
