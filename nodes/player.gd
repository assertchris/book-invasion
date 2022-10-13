extends CharacterBody2D
class_name GamePlayer

@onready var _agent := %Agent as NavigationAgent2D

var speed := 1000

func _ready() -> void:
	_agent.velocity_computed.connect(
		func(safe_velocity : Vector2) -> void:
			velocity = safe_velocity
			move_and_slide()
	)

	_agent.set_target_location(global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			_agent.set_target_location(event.position)
			_agent.get_next_location()

func _physics_process(delta: float) -> void:
	if not _agent.is_navigation_finished():
		var target := _agent.get_next_location()
		velocity = global_position.direction_to(target) * speed
		_agent.set_velocity(velocity)

func reposition(new_position : Vector2) -> void:
	position = new_position
	_agent.set_target_location(global_position)
	_agent.get_next_location()

var survivors := []
