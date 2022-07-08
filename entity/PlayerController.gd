extends KinematicBody2D

func _physics_process(delta):
	var speed = 500
	var velocity = Vector2()

	if $"/root/Player".spot_block != null:
		var blocks = $"/root/Blocks"
		var m = $"/root/Player".spot_block.material
		if m == blocks.SAND:
			speed *= 0.8
		elif m == blocks.WATER:
			speed *= 0.6
		elif m == blocks.LAVA:
			speed *= 0.4

	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		$Sprite.flip_h = true
	if Input.is_action_pressed("ui_right"):
		velocity.x = speed
		$Sprite.flip_h = false
	if Input.is_action_pressed("ui_up"):
		velocity.y = -speed
	if Input.is_action_pressed("ui_down"):
		velocity.y = speed

	move_and_slide(velocity, Vector2(0, 0))
	$"/root/Player".position = position
