extends KinematicBody2D

func _physics_process(delta):
	var speed = 500
	var velocity = Vector2()
	
	var blocks = $"/root/Blocks"
	var spot = $"/root/Player".spot_block
	if spot == blocks.SAND:
		speed *= 0.8
	elif spot == blocks.WATER:
		speed *= 0.6
	elif spot == blocks.LAVA:
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
