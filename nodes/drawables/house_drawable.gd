extends GameDrawable

func set_drawable_size(size : Vector2i) -> void:
	super.set_drawable_size(size)

	for group in get_children():
		for variation in group.get_children():
			variation.visible = false

	var intended_name := str(drawable_size.x) + "x" + str(drawable_size.y)
	var intended_node := get_node(intended_name)
	var index = randi() % intended_node.get_child_count()

	(intended_node.get_child(index) as TileMap).visible = true
