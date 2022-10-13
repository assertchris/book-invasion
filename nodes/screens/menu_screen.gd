extends GameScreen

@onready var _quit_button := %QuitButton as Button

func _ready() -> void:
	_quit_button.visible = not OS.has_feature("HTML5")

func _on_play_button_pressed() -> void:
	Screens.change_screen(Constants.screens.play)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
