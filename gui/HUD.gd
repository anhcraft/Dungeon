extends CanvasLayer

var rect_max_size = 0.0;
var target_ratio = 1.0;
var current_ratio = 1.0;

func _ready():
	rect_max_size = $EnergyBar.rect_size.x

func _process(delta):
	$Stats.text = str(Engine.get_frames_per_second()) + " fps | " + str($"/root/Player".position) + " | " + str($"../World".loaded_chunks.size()) + " loaded chunks"

	# energy bar animation
	target_ratio = $"/root/Player".get_energy_ratio()
	if abs(target_ratio - current_ratio) > 0.01:
		current_ratio = clamp(current_ratio + (target_ratio - current_ratio) * 0.1, 0.0, 1.0)
		if current_ratio > 0.98:
			$EnergyBar.hide()
			$EnergyBarBackground.hide()
		else:
			$EnergyBar.show()
			$EnergyBarBackground.show()
			$EnergyBar.rect_size.x = current_ratio * rect_max_size

	$HealthWarning.material.set_shader_param("bloody", $"/root/Player".get_health() < 20);
