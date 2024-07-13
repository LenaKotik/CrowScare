extends Node

signal parts_updated

export(Array, Texture) var part_textures

var parts = [0,0,0,0,0]

var _used_patterns = []

func generate_pattern(n):
	var pattern = []
	for _i in range(n):
		pattern.append(randi()%len(parts))
	if pattern in _used_patterns:
		pattern = generate_pattern(n) # scary
	_used_patterns.append(pattern)
	return pattern
