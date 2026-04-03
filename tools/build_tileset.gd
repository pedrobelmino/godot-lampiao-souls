extends SceneTree

func _init() -> void:
	call_deferred("_build")

func _build() -> void:
	var ts := TileSet.new()
	# Grade do mapa (world); atlas continua 32×32 por célula de arte.
	ts.tile_size = Vector2i(16, 16)
	ts.add_physics_layer(0)
	ts.set_physics_layer_collision_layer(0, 2)
	ts.set_physics_layer_collision_mask(0, 1)
	var atlas := TileSetAtlasSource.new()
	var abs_path := ProjectSettings.globalize_path("res://assets/tiles/sertao_tileset.png")
	var img := Image.load_from_file(abs_path)
	if img == null:
		push_error("build_tileset: missing or invalid PNG — run tools/gen_pixel_assets.py")
		quit(1)
		return
	var tex := ImageTexture.create_from_image(img)
	atlas.texture = tex
	atlas.texture_region_size = Vector2i(32, 32)
	ts.add_source(atlas, 0)
	var solid := [0, 1, 2, 4, 5]
	for x in range(8):
		var coords := Vector2i(x, 0)
		atlas.create_tile(coords)
		if x in solid:
			var td := atlas.get_tile_data(coords, 0)
			td.add_collision_polygon(0)
			td.set_collision_polygon_points(
				0,
				0,
				PackedVector2Array(
					[Vector2(0, 0), Vector2(32, 0), Vector2(32, 32), Vector2(0, 32)]
				)
			)
	var err := ResourceSaver.save(ts, "res://assets/tiles/sertao_tileset.tres")
	print("build_tileset: save=", err)
	quit(0 if err == OK else 1)
