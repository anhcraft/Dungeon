class_name BlockData

var material = 0
var in_cave = false

func is_liquid():
	return material == Blocks.WATER ||  material == Blocks.LAVA
