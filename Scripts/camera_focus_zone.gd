extends Area2D

## Camera focus zone: when the player steps in, their PlayerCamera pans to
## `focus_node` (or this zone's own position if none is set) and returns to
## normal follow when they leave — or after `hold_time` seconds if set.

## What the camera looks at; leave empty to focus on the zone itself.
@export var focus_node: Node2D
## Pan speed toward the focus point (same scale as cam_damping).
@export var focus_rate := 3.0
## > 1 pushes in, < 1 pulls out, 1 = no zoom change.
@export_range(0.25, 3.0) var focus_zoom := 1.0
## 0 = hold focus while the player stays inside; > 0 = release after
## this many seconds even if they remain in the zone.
@export var hold_time := 0.0
## Trigger only on the first entry.
@export var one_shot := false

var _used := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if _used or not body.is_in_group("Player"):
		return
	var cam := _camera_of(body)
	if cam == null:
		return
	if one_shot:
		_used = true
	var point := focus_node.global_position if focus_node != null else global_position
	cam.focus_on(point, focus_rate, focus_zoom)
	if hold_time > 0.0:
		get_tree().create_timer(hold_time).timeout.connect(cam.end_focus)


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	var cam := _camera_of(body)
	if cam != null:
		cam.end_focus()


func _camera_of(body: Node2D) -> PlayerCamera:
	return body.get_node_or_null("PlayerCamera") as PlayerCamera
