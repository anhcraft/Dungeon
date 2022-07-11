extends KinematicBody2D

func _physics_process(delta):
	var speed = 1000
	var velocity = Vector2()

	if $"/root/Player".spot_block != null:
		var blocks = $"/root/Blocks"
		var m = $"/root/Player".spot_block.material
		if m == blocks.SAND:
			speed *= 0.8
		elif m == blocks.WATER:
			speed *= 0.4
		elif m == blocks.LAVA:
			speed *= 0.3
		
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

	move_and_slide(velocity, Vector2(0, 0))
	$"/root/Player".position = position
