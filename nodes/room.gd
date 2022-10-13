extends Node2D
class_name GameRoom

@onready var _tiles := %Tiles as TileMap
@onready var _doodads := %Doodads as Node2D

var layout : Array

func _ready() -> void:
	layout = Generation.get_room_layout()

	Generation.add_room_tiles(_tiles, layout)
	Generation.add_room_doodads(_doodads, layout)

	spawn_survivors()

var room_type : Types.rooms
var room_position : Vector2i
var sanctuary_side : Types.room_neighbors

func get_neighbor_positions() -> Dictionary:
	return {
		Types.room_neighbors.top: Vector2i(room_position.x, room_position.y - 1),
		Types.room_neighbors.right: Vector2i(room_position.x + 1, room_position.y),
		Types.room_neighbors.bottom: Vector2i(room_position.x, room_position.y + 1),
		Types.room_neighbors.left: Vector2i(room_position.x - 1, room_position.y),
	}

func get_neighbor_position(neighbor : Types.room_neighbors) -> Vector2i:
	return get_neighbor_positions()[neighbor]

func has_neighbor(neighbor : Types.room_neighbors) -> bool:
	var neighbor_position = get_neighbor_position(neighbor)
	return Variables.room_positions_taken.has(neighbor_position)

func get_neighbor(neighbor : Types.room_neighbors) -> GameRoom:
	var neighbor_position = get_neighbor_position(neighbor)

	for next_room in Variables.rooms:
		if next_room.room_position == neighbor_position:
			return next_room

	return null

func free_side() -> int:
	for neighbor in Types.room_neighbors.values():
		if not has_neighbor(neighbor):
			return neighbor

	return -1

@onready var _sanctuaries := %Sanctuaries as Node2D
@onready var _arrows := %Arrows as Node2D

func hide_invalid_stuff() -> void:
	for node in _sanctuaries.get_children():
		node.visible = false

	for node in _arrows.get_children():
		node.visible = false

	for side in ["top", "right", "bottom", "left"]:
		var name = side.capitalize()

		if has_neighbor(Types.room_neighbors[side]):
			_arrows.get_node(name).visible = true

		if [Types.rooms.first, Types.rooms.last].has(room_type):
			if sanctuary_side == Types.room_neighbors[side]:
				_sanctuaries.get_node(name).visible = true

func add_player(side : Types.room_neighbors) -> void:
	call_deferred("disable_colliders")
	await get_tree().create_timer(0.1).timeout

	var old_room = Variables.player.get_parent()

	if old_room:
		old_room.remove_child(Variables.player)
		old_room.position = Vector2(-999, -999)

		for survivor in Variables.player.survivors:
			survivor.get_parent().remove_child(survivor)

	position = Vector2(-66, -66)
	add_child(Variables.player)

	Variables.player.reposition(get_spawn_position(side))

	for survivor in Variables.player.survivors:
		_survivors.add_child(survivor)
		survivor.reposition(Variables.player.global_position)

	await get_tree().create_timer(0.1).timeout
	call_deferred("enable_colliders")

func disable_colliders() -> void:
	get_tree().call_group("exit_colliders", "set_disabled", true)

func enable_colliders() -> void:
	get_tree().call_group("exit_colliders", "set_disabled", false)

@onready var _spawns := %Spawns as Node2D

func get_spawn_position(neighbor : Types.room_neighbors) -> Vector2:
	var spawn_name := Types.room_neighbors.keys()[neighbor].capitalize() as String
	var spawn_node := _spawns.get_node(spawn_name) as Marker2D

	return spawn_node.position

func _on_top_body_entered(body : PhysicsBody2D) -> void:
	if not body is GamePlayer:
		return

	var from_side = Types.room_neighbors.top

	if room_type == Types.rooms.first:
		rescue_survivors(from_side)

	if has_neighbor(from_side):
		get_neighbor(from_side).add_player(Types.room_neighbors.bottom)

func _on_right_body_entered(body : PhysicsBody2D) -> void:
	if not body is GamePlayer:
		return

	var from_side = Types.room_neighbors.right

	if room_type == Types.rooms.first:
		rescue_survivors(from_side)

	if has_neighbor(from_side):
		get_neighbor(from_side).add_player(Types.room_neighbors.left)

func _on_bottom_body_entered(body : PhysicsBody2D) -> void:
	if not body is GamePlayer:
		return

	var from_side = Types.room_neighbors.bottom

	if room_type == Types.rooms.first:
		rescue_survivors(from_side)

	if has_neighbor(from_side):
		get_neighbor(from_side).add_player(Types.room_neighbors.top)

func _on_left_body_entered(body : PhysicsBody2D) -> void:
	if not body is GamePlayer:
		return

	var from_side = Types.room_neighbors.left

	if room_type == Types.rooms.first:
		rescue_survivors(from_side)

	if has_neighbor(from_side):
		get_neighbor(from_side).add_player(Types.room_neighbors.right)

func rescue_survivors(side : Types.room_neighbors) -> void:
	if side != sanctuary_side:
		return

	for survivor in Variables.player.survivors:
		Variables.player.survivors.erase(survivor)
		survivor.queue_free()

@onready var _survivors := %Survivors as Node2D

func spawn_survivors() -> void:
	var used_coordinates : Array[Vector2i] = []

	for i in randi_range(Constants.minimum_survivors_in_room, Constants.maximum_survivors_in_room):
		var survivor := Constants.survivor_scene.instantiate() as GameSurvivor
		_survivors.add_child(survivor)

		var coordinates = Vector2i(randi() % Constants.layout_width, randi() % Constants.layout_width)
		var drawable_type = layout[coordinates.y][coordinates.x]

		while drawable_type != Types.drawables.grass or used_coordinates.has(coordinates):
			coordinates = Vector2i(randi() % Constants.layout_width, randi() % Constants.layout_width)
			drawable_type = layout[coordinates.y][coordinates.x]

		used_coordinates.push_back(coordinates)

		survivor.reposition(coordinates * Constants.sprite_width)
