# recast.gd
extends LimboState

func _enter() -> void:
	agent.sprite.play("death")
	await agent.sprite.animation_finished

	# capture spawn data before the body is freed
	var parent: Node      = agent.get_parent()
	var spawn_pos: Vector2 = agent.global_position
	var scene_path: String = agent.scene_file_path

	# the Captain already decided recast vs true death during take_damage.
	# is_active() is true only if the role recast (form restored, role kept).
	# on true death the role is cleared, so we do not respawn. the stage goes quiet.
	print(Captain.is_active() ," and ", scene_path != "")
	if Captain.is_active() and scene_path != "":
		_respawn_vessel(parent, spawn_pos, scene_path)

	agent.queue_free()

func _respawn_vessel(parent: Node, spawn_pos: Vector2, scene_path: String) -> void:
	var vessel: Node2D = load(scene_path).instantiate()
	parent.call_deferred("add_child", vessel)
	vessel.set_deferred("global_position", spawn_pos)
