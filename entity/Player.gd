extends Node

var position = Vector2(0, 0)
var spot_block = null
var max_energy = 100.0
var _energy = 100.0

func set_energy(v: float):
	_energy = min(v, max_energy)

func consume_energy(d: float):
	var remain = _energy - d
	if remain >= 0:
		_energy = remain
	return remain >= 0

func supply_energy(d: float):
	var comming = _energy + d
	if comming <= max_energy:
		_energy = comming
	return comming <= max_energy

func get_energy():
	return _energy

func get_energy_ratio():
	return _energy/max_energy
