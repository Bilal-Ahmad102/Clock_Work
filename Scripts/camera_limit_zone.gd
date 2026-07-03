extends Area2D

## Room-scoped camera limits taken from shape bounds: while the player is
## inside this zone, the camera is confined to the bounding box of
## `bounds_node` — or of this zone's own collision shapes if none is set —
## intersected with the level's base limits, so it can only tighten them.
## Leaving restores the level limits. The camera's own damping eases the
## transition both ways, like a focus zone.
##
## Regions narrower than the viewport (1152x648 at zoom 1) lock the camera
## to the region's center on that axis.

## Optional node whose shape defines the camera region, for when the
## trigger area and the camera bounds differ. Accepts a Polygon2D,
## CollisionPolygon2D or CollisionShape2D (can be invisible). Leave empty
## to use this zone's own collision shapes as the region.
@export var bounds_node: Node2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	var cam := _camera_of(body)
	if cam == null:
		return
	var region := _region_bounds()
	cam.set_limit_region(
		roundi(region.position.x), roundi(region.position.y),
		roundi(region.end.x), roundi(region.end.y))


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("Player"):
		return
	var cam := _camera_of(body)
	if cam != null:
		cam.clear_limit_region()


## Global-space bounding box of the region-defining shape(s).
func _region_bounds() -> Rect2:
	var points := PackedVector2Array()
	if bounds_node != null:
		points = _node_points(bounds_node)
	else:
		for child in get_children():
			points.append_array(_node_points(child))
	var rect := Rect2()
	for i in points.size():
		rect = Rect2(points[i], Vector2.ZERO) if i == 0 else rect.expand(points[i])
	return rect


func _node_points(node: Node) -> PackedVector2Array:
	var local := PackedVector2Array()
	if node is CollisionPolygon2D or node is Polygon2D:
		local = node.polygon
	elif node is CollisionShape2D and node.shape != null:
		var r: Rect2 = node.shape.get_rect()
		local = PackedVector2Array([
			r.position, Vector2(r.end.x, r.position.y),
			r.end, Vector2(r.position.x, r.end.y),
		])
	var pts := PackedVector2Array()
	for p in local:
		pts.append(node.to_global(p))
	return pts


func _camera_of(body: Node2D) -> PlayerCamera:
	return body.get_node_or_null("PlayerCamera") as PlayerCamera
