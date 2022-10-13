extends MarginContainer
class_name GameScreen

signal did_prepare_to_hide
signal did_hide_with_transition
signal did_prepare_to_show
signal did_show_with_transition

@onready var _cover := %Cover as ColorRect

var duration := 1.0

func prepare_to_hide(next_screen : Types.screens) -> void:
	_cover.material.set_shader_parameter("amount", 0.1)
	did_prepare_to_hide.emit()

func hide_with_transition(next_screen : Types.screens) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(func(value): _cover.material.set_shader_parameter("amount", value), 0.0, 1.0, duration)
	await tween.finished

	did_hide_with_transition.emit()

func prepare_to_show(previous_screen : Types.screens) -> void:
	did_prepare_to_show.emit()

func show_with_transition(previous_screen : Types.screens) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(func(value): _cover.material.set_shader_parameter("amount", value), 1.0, 0.0, duration)
	await tween.finished

	did_show_with_transition.emit()
