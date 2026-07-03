class_name PlayerCamera
extends Camera2D

## Damped follow camera. All tuning lives as @export values in the Camera
## group of player.gd — player.gd pushes them in via _configure_camera(),
## so everything here stays a plain var (one place to tune, per CLAUDE.md).

var target: Node2D

var follow_offset := Vector2(0, -40)
## Catch-up rate per axis; higher = stiffer, ~0 = frozen.
var damping := Vector2(6.0, 4.0)
## 0 = raw damped follow; toward 1 adds a soft second smoothing pass
## that rounds off sudden direction changes.
var smoothing := 0.15
## Half-size of the box the target can roam before the camera follows.
var deadzone := Vector2(24.0, 32.0)

## Pixels the camera leads in the direction of travel.
var lookahead := 60.0
var lookahead_speed := 2.5
## Extra downward look while falling faster than fall_speed_threshold.
var fall_lookdown := 50.0
var fall_speed_threshold := 200.0

var _anchor := Vector2.ZERO  # deadzone-tracked focus point
var _look := Vector2.ZERO    # smoothed lookahead offset
var _damped := Vector2.ZERO  # first-stage damped position

var _focus_active := false
var _focus_point := Vector2.ZERO
var _focus_rate := 3.0
var _focus_zoom := 1.0
var _base_zoom := Vector2.ONE

var _base_limit_left := -10000000
var _base_limit_top := -10000000
var _base_limit_right := 10000000
var _base_limit_bottom := 10000000
var _region_active := false
var _region := Rect2()


func _ready() -> void:
	top_level = true
	_base_zoom = zoom
	if target != null:
		snap_to_target()


func _physics_process(delta: float) -> void:
	if target == null:
		return

	var focus := target.global_position + follow_offset

	# The anchor only moves when the focus escapes the deadzone box around it.
	_anchor.x = clampf(_anchor.x, focus.x - deadzone.x, focus.x + deadzone.x)
	_anchor.y = clampf(_anchor.y, focus.y - deadzone.y, focus.y + deadzone.y)

	var desired_look := Vector2.ZERO
	if not _focus_active:
		var vel := Vector2.ZERO
		if target is CharacterBody2D:
			vel = (target as CharacterBody2D).velocity
		if absf(vel.x) > 5.0:
			desired_look.x = signf(vel.x) * lookahead
		if vel.y > fall_speed_threshold:
			desired_look.y = fall_lookdown
	_look = _look.lerp(desired_look, _decay(lookahead_speed, delta))

	# Two-stage follow: per-axis damped catch-up, then an optional extra
	# smoothing pass on top. While a focus is active the goal is the focus
	# point instead; _anchor keeps tracking the player so the return pan
	# is seamless.
	var goal := _focus_point if _focus_active else _anchor + _look
	if _region_active:
		goal = _clamp_to_region(goal)
	var rate := Vector2(_focus_rate, _focus_rate) if _focus_active else damping
	_damped.x = lerpf(_damped.x, goal.x, _decay(rate.x, delta))
	_damped.y = lerpf(_damped.y, goal.y, _decay(rate.y, delta))
	if smoothing > 0.0:
		var soft_rate := lerpf(30.0, 4.0, smoothing)
		global_position = global_position.lerp(_damped, _decay(soft_rate, delta))
	else:
		global_position = _damped

	var goal_zoom := _base_zoom * _focus_zoom if _focus_active else _base_zoom
	zoom = zoom.lerp(goal_zoom, _decay(_focus_rate, delta))


## Pan toward a world point (deadzone and lookahead suspended) until
## end_focus() is called. `zoom_factor` > 1 pushes in, < 1 pulls out.
func focus_on(point: Vector2, rate: float = 3.0, zoom_factor: float = 1.0) -> void:
	_focus_active = true
	_focus_point = point
	_focus_rate = rate
	_focus_zoom = zoom_factor


## Release the focus; the camera pans back to normal follow.
func end_focus() -> void:
	_focus_active = false


## The level-wide limits (set from the player's cam_limit_* exports).
## These stay on the built-in hard limits; regions are applied softly.
func set_base_limits(l: int, t: int, r: int, b: int) -> void:
	_base_limit_left = l
	_base_limit_top = t
	_base_limit_right = r
	_base_limit_bottom = b
	limit_left = l
	limit_top = t
	limit_right = r
	limit_bottom = b


## Confine the camera to a region while the player is inside it. The region
## is intersected with the base limits, so a zone can only confine the
## camera further, never let it leave the level bounds. Applied as a soft
## clamp on the follow goal, so the regular damping eases the camera in
## and out — no hard limit snapping.
func set_limit_region(l: int, t: int, r: int, b: int) -> void:
	var left := maxi(l, _base_limit_left)
	var top := maxi(t, _base_limit_top)
	var right := mini(r, _base_limit_right)
	var bottom := mini(b, _base_limit_bottom)
	_region = Rect2(left, top, right - left, bottom - top)
	_region_active = true


## Release the region; the camera eases back to level-wide limits.
func clear_limit_region() -> void:
	_region_active = false


## Clamps a desired camera center so the visible view stays inside the
## region; axes narrower than the view lock to the region's center.
func _clamp_to_region(center: Vector2) -> Vector2:
	var half := get_viewport_rect().size * 0.5 / zoom
	if _region.size.x >= half.x * 2.0:
		center.x = clampf(center.x, _region.position.x + half.x, _region.end.x - half.x)
	else:
		center.x = _region.get_center().x
	if _region.size.y >= half.y * 2.0:
		center.y = clampf(center.y, _region.position.y + half.y, _region.end.y - half.y)
	else:
		center.y = _region.get_center().y
	return center


## Center instantly on the target — call after spawns, respawns, teleports.
func snap_to_target() -> void:
	if target == null:
		return
	_focus_active = false
	zoom = _base_zoom
	_anchor = target.global_position + follow_offset
	_look = Vector2.ZERO
	_damped = _anchor
	global_position = _anchor
	reset_smoothing()


## Frame-rate-independent lerp weight for an exponential decay `rate`.
func _decay(rate: float, delta: float) -> float:
	return 1.0 - exp(-rate * delta)
