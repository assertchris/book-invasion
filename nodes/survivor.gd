extends CharacterBody2D
class_name GameSurvivor

@onready var _agent := %Agent as NavigationAgent2D

var speed := 1000

func _ready() -> void:
	_agent.velocity_computed.connect(
		func(safe_velocity : Vector2) -> void:
			velocity = safe_velocity
			move_and_slide()
	)

	_agent.set_target_location(global_position)

func _physics_process(delta: float) -> void:
	if not _agent.is_navigation_finished():
		var target := _agent.get_next_location()
		velocity = global_position.direction_to(target) * speed
		_agent.set_velocity(velocity)

func reposition(new_position : Vector2) -> void:
	position = new_position
	_agent.set_target_location(global_position)
	_agent.get_next_location()

@onready var _follow_timer := %FollowTimer as Timer

var following : GamePlayer

func _on_follow_timer_timeout() -> void:
	if not following and Variables.player.global_position.distance_to(global_position) < 50:
		following = Variables.player
		Variables.player.survivors.push_back(self)

	if following:
		_agent.set_target_location(
			following.global_position
		)
