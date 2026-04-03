extends Node2D

## Célula do TileMap em que o jogador apoia os pés (topo da célula = y * tile_size.y).
@export var spawn_tile: Vector2i = Vector2i(3, 15)

func _get_map() -> String:
	return ""


func _char_to_tile(ch: String) -> int:
	match ch:
		".", " ":
			return -1
		"g":
			return 0
		"t":
			return 1
		"p":
			return 2
		"m":
			return 3
		"c":
			return 4
		"r":
			return 5
		"x":
			return 6
		"w":
			return 7
		_:
			return -1


func _apply_ascii(layer: TileMapLayer, map_string: String) -> void:
	var rows := map_string.strip_edges().split("\n")
	for y in range(rows.size()):
		var row: String = rows[y]
		for x in range(row.length()):
			var tid := _char_to_tile(row[x])
			if tid >= 0:
				layer.set_cell(Vector2i(x, y), 0, Vector2i(tid, 0), 0)


func _ready() -> void:
	var layer: TileMapLayer = $TileMapLayer
	layer.tile_set = load("res://assets/tiles/sertao_tileset.tres") as TileSet
	var m := _get_map()
	if m.is_empty():
		push_error("sertao_stage_base: empty map")
		return
	_apply_ascii(layer, m)
	if has_node(^"Player"):
		var cell := Vector2i(16, 16)
		if layer.tile_set:
			cell = layer.tile_set.tile_size
		var p: Node2D = $Player
		p.global_position = Vector2(
			float(spawn_tile.x) * cell.x + cell.x * 0.5,
			float(spawn_tile.y) * cell.y
		)
