extends GameScreen

@onready var _stage := %Stage as Control

func _ready() -> void:
	Generation.make_rooms(_stage)

	Variables.player = Constants.player_scene.instantiate()
	Variables.rooms[0].add_player(Types.room_neighbors.top)
