extends Node2D

func _ready():
	pass

func _exit_tree():
	$World.render_terminated = true

func _process(delta):
	$HUD/Stats.text = str(Engine.get_frames_per_second()) + " fps | " + str($"/root/Player".position) + " | " + str($World.loaded_chunks.size()) + " loaded chunks"
