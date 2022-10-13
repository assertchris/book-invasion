extends GameDrawable

func _ready() -> void:
	var chance := randf()
	var sprites := get_children()

	for sprite in sprites:
		sprite.visible = false

	if chance >= 0.90:
		sprites[1].visible = true
	elif chance >= 0.80:
		sprites[0].visible = true
