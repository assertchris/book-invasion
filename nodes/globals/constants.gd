extends Node
class_name Types

@export var game_over_scene : PackedScene
@export var menu_scene : PackedScene
@export var play_scene : PackedScene
@export var summary_scene : PackedScene

enum screens {
	game_over,
	menu,
	play,
	summary,
}

@onready var screen_scenes := {
	screens.game_over: game_over_scene,
	screens.menu: menu_scene,
	screens.play: play_scene,
	screens.summary: summary_scene,
}

@export var tree_scene : PackedScene
@export var grave_scene : PackedScene
@export var house_scene : PackedScene
@export var grass_scene : PackedScene

enum drawables {
	tree,
	grave,
	house,
	grass,
	path,
}

@onready var drawable_scenes := {
	drawables.tree: tree_scene,
	drawables.grave: grave_scene,
	drawables.house: house_scene,
	drawables.grass: grass_scene,
}

var drawable_colors := {
	drawables.tree: "22c55e",
	drawables.grave: "71717a",
	drawables.house: "ef4444",
	drawables.grass: "fbbf24",
	drawables.path: "a855f7",
}

var drawable_tiles := [
	drawables.path,
]

var drawable_groups := [
	drawables.house,
]

var number_of_layouts := 8
var layout_width := 11
var sprite_width := 12

@export var room_scene : PackedScene

var number_of_rooms := 8

enum rooms {
	first,
	other,
	last,
}

enum room_neighbors {
	top,
	right,
	bottom,
	left,
}

@export var player_scene : PackedScene

@export var survivor_scene : PackedScene

var minimum_survivors_in_room := 0
var maximum_survivors_in_room := 1
