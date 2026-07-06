extends Node2D

## Blockout gate: stays shut until every target in `watch` emits `broke`,
## then stops colliding and fades so the opening reads on screen.

@export var watch: Array[NodePath] = []
@export var kill_area : Area2D
var _remaining: int = 0

func _ready() -> void:
	if !kill_area:
		kill_area = get_child(0) if get_child(0) else null
	for path in watch:
		var target := get_node_or_null(path)
		if target != null and target.has_signal("broke"):
			target.broke.connect(_on_target_broke)
			_remaining += 1
	if _remaining == 0:
		push_warning("training_gate '%s' watches nothing — it will stay shut" % name)

func _on_target_broke(_by_atk: StringName) -> void:
	_remaining -= 1
	if _remaining <= 0:
		open()

func open() -> void:
	if kill_area:
		kill_area.queue_free()
	set_deferred("collision_layer", 0)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.12, 0.4)
