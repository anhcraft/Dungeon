extends Node2D

func _ready():
	pass

func _exit_tree():
	$World.render_terminated = true
