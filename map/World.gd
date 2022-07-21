extends TileMap

const entity_slime = preload("res://../entity/Slime.tscn")
const view_distance = 3

var biome_noise = OpenSimplexNoise.new()
var area_noise = OpenSimplexNoise.new()
var force_render = true
var render_terminated = false
var loaded_chunks = {}
var loaded_entities = {}

var biome_scale = 0.2;
var area_scale = 0.3;

func _ready():
	biome_noise.seed = randi()
	biome_noise.period = 1
	biome_noise.lacunarity = 1
	biome_noise.persistence = 1
	biome_noise.octaves = 1

	area_noise.seed = randi() + 1
	area_noise.period = 1
	area_noise.lacunarity = 1
	area_noise.persistence = 1
	area_noise.octaves = 1

	var thread = Thread.new()
	thread.start(self, "_world_rendering", "")

func _process(delta):
	var mt5 = tile_set.tile_get_material(5);
	mt5.set_shader_param("global_transform", get_global_transform())
	var mt6 = tile_set.tile_get_material(6);
	mt6.set_shader_param("global_transform", get_global_transform())

func _reversed_dist(i: float, j: float, a: float, b: float, d: float):
	return 1.0 - (sqrt((pow(i - a, 2) + pow(j - b, 2)) / (2 * pow(d, 2))))

func _compute_biome_noise(offset_x: float, offset_y: float, chunk_x: int, chunk_y: int):
	var x = (chunk_x << 4) + offset_x
	x *= biome_scale
	var y = (chunk_y << 4) + offset_y
	y *= biome_scale
	return (biome_noise.get_noise_2d(x, y) + 1) * 0.5

func _compute_area_noise(offset_x: float, offset_y: float, chunk_x: int, chunk_y: int):
	var x = (chunk_x << 4) + offset_x
	x *= area_scale
	var y = (chunk_y << 4) + offset_y
	y *= area_scale
	return (area_noise.get_noise_2d(x, y) + 1) * 0.5

func load_chunk(chunk_x: int, chunk_y: int):
	var pos = Vector2(chunk_x, chunk_y)
	if loaded_chunks.has(pos):
		return
	
	var biome_quad = [
		_compute_biome_noise(0, 0, chunk_x, chunk_y),
		_compute_biome_noise(15, 0, chunk_x, chunk_y),
		_compute_biome_noise(0, 15, chunk_x, chunk_y),
		_compute_biome_noise(15, 15, chunk_x, chunk_y),
		_compute_biome_noise(7.5, 7.5, chunk_x, chunk_y)
	]

	var area_quad = [
		_compute_area_noise(0, 0, chunk_x, chunk_y),
		_compute_area_noise(15, 0, chunk_x, chunk_y),
		_compute_area_noise(0, 15, chunk_x, chunk_y),
		_compute_area_noise(15, 15, chunk_x, chunk_y),
		_compute_area_noise(7.5, 7.5, chunk_x, chunk_y)
	]

	var block = $"/root/Blocks"
	var data = []
	for i in 16:
		data.push_back([])
		for j in 16:
			var d = [
				_reversed_dist(i, j, 0, 0, 15),
				_reversed_dist(i, j, 15, 0, 15),
				_reversed_dist(i, j, 0, 15, 15),
				_reversed_dist(i, j, 15, 15, 15),
				_reversed_dist(i, j, 7.5, 7.5, 7.5)
			]

			var bn = biome_quad[0] * d[0] + biome_quad[1] * d[1] + biome_quad[2] * d[2] + biome_quad[3] * d[3] + biome_quad[4] * d[4]
			bn /= d[0] + d[1] + d[2] + d[3] + d[4]
			bn = clamp(bn, 0, 1)

			var an = area_quad[0] * d[0] + area_quad[1] * d[1] + area_quad[2] * d[2] + area_quad[3] * d[3] + area_quad[4] * d[4]
			an /= d[0] + d[1] + d[2] + d[3] + d[4]
			an = clamp(an, 0, 1)

			var bd = BlockData.new()
			var m = block.GRASS
			if an < 0.4:
				if bn < 0.5:
					m = block.GRASS
				elif bn < 0.7:
					m = block.SAND
				else:
					m = block.WATER
			elif (an < 0.5) and (bn > 0.4):
				m = block.WALL
			else:
				bd.in_cave = true
				if bn < 0.5:
					m = block.STONE
				elif (abs(an - 0.7) < 0.1) and (bn < 0.6):
					m = block.LAVA
				else:
					m = block.DIRT

			bd.material = m
			data[i].append(bd)

	loaded_chunks[pos] = data
	call_deferred("_update_data", chunk_x, chunk_y, data)

func _update_data(chunk_x: int, chunk_y: int, data):
	var pos = Vector2(chunk_x, chunk_y)
	loaded_entities[pos] = 0
	for i in 16:
		for j in 16:
			var x = (chunk_x << 4) + i
			var y = (chunk_y << 4) + j
			set_cell(x, y, data[i][j].material)

	if loaded_entities[pos] < 3:
		for k in 3:
			var i = rand_range(0, 15)
			var j = rand_range(0, 15)
			var x = (chunk_x << 4) + i
			var y = (chunk_y << 4) + j
			if data[i][j].material == $"/root/Blocks".WALL:
				continue
			var ent = entity_slime.instance()
			ent.position = Vector2(x, y) * 64
			add_child(ent)
			loaded_entities[pos] += 1
	update_bitmask_region()

##################################################################

var _last_chunk_x = 99
var _last_chunk_y = 99

func _world_rendering(_u):
	while not render_terminated:
		var pos = $"/root/Player".position;
		var chunk_x = (pos.x as int >> 6) >> 4
		var chunk_y = (pos.y as int >> 6) >> 4
		var local_x = (pos.x as int >> 6) & 15
		var local_y = (pos.y as int >> 6) & 15
		if (not force_render) and (chunk_x == _last_chunk_x) and (chunk_y == _last_chunk_y):
			continue
		force_render = false
		for i in view_distance * 2:
			for j in view_distance * 2:
				load_chunk(chunk_x + i - view_distance, chunk_y + j - view_distance)
		$"/root/Player".spot_block = (loaded_chunks.get(Vector2(chunk_x, chunk_y)) as Array)[local_x][local_y]

##################################################################

func clean_up_chunks(data: Dictionary):
	var to_deleted = []
	for s in loaded_chunks.keys():
		if data.has(s):
			continue
		to_deleted.append(s)
	for s in to_deleted:
		var pos = s as Vector2
		for i in 16:
			for j in 16:
				var x = ((pos.x as int) << 4) + i
				var y = ((pos.y as int) << 4) + j
				set_cell(x, y, -1)
				
		loaded_chunks.erase(s)
	update_bitmask_region()

func _on_ChunkCleaner_timeout():
	var pos = $"/root/Player".position;
	var chunk_x = (pos.x as int >> 6) >> 4
	var chunk_y = (pos.y as int >> 6) >> 4
	var viewable_chunks = {}
	for i in view_distance * 2:
		for j in view_distance * 2:
			var x = chunk_x + i - view_distance
			var y = chunk_y + j - view_distance
			viewable_chunks[Vector2(x, y)] = true
	clean_up_chunks(viewable_chunks)

##################################################################
