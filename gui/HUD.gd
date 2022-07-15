extends CanvasLayer

func _process(delta):
	$Stats.text = str(Engine.get_frames_per_second()) + " fps | " + str($"/root/Player".position) + " | " + str($"../World".loaded_chunks.size()) + " loaded chunks"
