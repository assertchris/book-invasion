extends Node

@export var layout_texture : Texture2D

func _ready() -> void:
	randomize()

func get_room_layout() -> Array:
	var image := layout_texture.get_image()
	var offset : int = (randi() % Constants.number_of_layouts) * Constants.layout_width
	var room := []

	for y in range(Constants.layout_width):
		var row := []

		for x in range(Constants.layout_width):
			var drawable_type : Types.drawables
			var pixel_color = image.get_pixel(x + offset, y).to_html(false)

			for type in Constants.drawable_colors.keys():
				if pixel_color == Constants.drawable_colors[type]:
					drawable_type = type

			row.push_back(drawable_type)

		room.push_back(row)

	return room

func add_room_tiles(tilemap : TileMap, layout : Array) -> void:
	var tiles : Array[Vector2i] = []

	for y in range(Constants.layout_width):
		for x in range(Constants.layout_width):
			if not layout[y][x] in Constants.drawable_tiles:
				continue

			tiles.push_back(Vector2i(x, y))

	tilemap.set_cells_terrain_connect(0, tiles, 0, 0, false)

func add_room_doodads(node : Node2D, layout : Array) -> void:
	var ignored : Array[Vector2i] = []

	for y in range(Constants.layout_width):
		for x in range(Constants.layout_width):
			var current : Types.drawables = layout[y][x]

			if ignored.has(Vector2i(x, y)):
				continue

			if not Constants.drawable_scenes.keys().has(current):
				continue

			var drawable_size : Vector2i

			if current in Constants.drawable_groups:
				var w := 0
				var h := 0

				for i in range(5):
					if layout[y + i][x] != current:
						break

					for j in range(5):
						if layout[y + i][x + j] != current:
							break

						ignored.append(Vector2i(x + j, y + i))

						if i == 0:
							w += 1

					h += 1

				drawable_size = Vector2i(w, h)

			var drawable = Constants.drawable_scenes[current].instantiate() as GameDrawable
			node.add_child(drawable)

			drawable.set_drawable_size(drawable_size)

			drawable.position = Vector2(
				x * Constants.sprite_width,
				y * Constants.sprite_width,
			)

func make_rooms(parent) -> void:
	Variables.room_positions_available = []
	Variables.room_positions_taken = []
	Variables.rooms = []

	var first_room = Constants.room_scene.instantiate() as GameRoom
	parent.add_child(first_room)
	first_room.room_position = Vector2i(0, 0)
	first_room.room_type = Constants.rooms.first
	first_room.position = Vector2(-66, -66)

	var rooms_left = Constants.number_of_rooms - 1

	Variables.room_positions_available += first_room.get_neighbor_positions().values()
	Variables.room_positions_taken.append(first_room.room_position)
	Variables.rooms.append(first_room)

	Variables.room_positions_available.erase(
		Variables.room_positions_available[randi() % Variables.room_positions_available.size()]
	)

	while rooms_left > 0:
		var next_room_position = Variables.room_positions_available[randi() % Variables.room_positions_available.size()]
		Variables.room_positions_available.erase(next_room_position)

		var next_room_type : Types.rooms

		if rooms_left == 1:
			next_room_type = Types.rooms.last
		else:
			next_room_type = Types.rooms.other

		var next_room = Constants.room_scene.instantiate() as GameRoom
		parent.add_child(next_room)
		next_room.room_position = next_room_position
		next_room.room_type = next_room_type
		next_room.position = Vector2(-999, -999)

		if next_room_type == Types.rooms.last:
			var free_side = next_room.free_side()
			next_room.sanctuary_side = free_side

		Variables.room_positions_taken.append(next_room_position)
		Variables.rooms.append(next_room)

		for neighbor_position in next_room.get_neighbor_positions().values():
			if not Variables.room_positions_taken.has(neighbor_position) and not Variables.room_positions_available.has(neighbor_position):
				Variables.room_positions_available.append(neighbor_position)

		rooms_left -= 1

	var free_side = first_room.free_side()
	first_room.sanctuary_side = free_side

	for room in Variables.rooms:
		room.hide_invalid_stuff()
