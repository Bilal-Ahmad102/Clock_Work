@tool
extends GPUParticles2D

@export_group("Look")
## Tint applied to the grayscale leaf texture — pick any leaf color here.
@export var leaf_color: Color = Color(0.27, 0.49, 0.11):
	set(v):
		leaf_color = v
		_apply()
## Random hue shift per leaf, for natural color variety.
@export_range(0.0, 0.5) var hue_variation: float = 0.04:
	set(v):
		hue_variation = v
		_apply()
@export var leaf_scale_min: float = 1.0:
	set(v):
		leaf_scale_min = v
		_apply()
@export var leaf_scale_max: float = 2.0:
	set(v):
		leaf_scale_max = v
		_apply()

@export_group("Motion")
## Downward fall speed in pixels per second.
@export var fall_speed: float = 45.0:
	set(v):
		fall_speed = v
		_apply()
## 0 = all leaves same speed, 1 = speeds vary from 0 up to fall_speed.
@export_range(0.0, 1.0) var speed_randomness: float = 0.4:
	set(v):
		speed_randomness = v
		_apply()
## Emission cone half-angle in degrees.
@export_range(0.0, 180.0) var spread_degrees: float = 25.0:
	set(v):
		spread_degrees = v
		_apply()
## Constant horizontal push; positive drifts leaves right.
@export var wind: float = 8.0:
	set(v):
		wind = v
		_apply()
## Turbulence strength for fluttery, swirling descent. 0 disables.
@export_range(0.0, 1.0) var swirl: float = 0.3:
	set(v):
		swirl = v
		_apply()
## Max spin speed per leaf, degrees per second (each leaf gets a random value).
@export var rotate_speed: float = 60.0:
	set(v):
		rotate_speed = v
		_apply()

@export_group("Emission")
@export_range(1, 500) var leaves_amount: int = 24:
	set(v):
		leaves_amount = v
		_apply()
## Width of the horizontal band leaves spawn from, in pixels.
@export var emit_width: float = 320.0:
	set(v):
		emit_width = v
		_apply()
## Seconds each leaf lives before disappearing.
@export var leaf_lifetime: float = 6.0:
	set(v):
		leaf_lifetime = v
		_apply()


func _ready() -> void:
	_apply()


func _apply() -> void:
	if not is_node_ready():
		return
	var mat := process_material as ParticleProcessMaterial
	if mat == null:
		mat = ParticleProcessMaterial.new()
		process_material = mat

	amount = leaves_amount
	lifetime = maxf(0.1, leaf_lifetime)
	preprocess = lifetime * 0.5

	mat.color = leaf_color
	mat.hue_variation_min = -hue_variation
	mat.hue_variation_max = hue_variation
	mat.scale_min = leaf_scale_min
	mat.scale_max = leaf_scale_max

	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = spread_degrees
	mat.initial_velocity_min = fall_speed * (1.0 - speed_randomness)
	mat.initial_velocity_max = fall_speed
	mat.gravity = Vector3(wind, fall_speed * 0.3, 0.0)

	mat.angle_min = -180.0
	mat.angle_max = 180.0
	mat.angular_velocity_min = -rotate_speed
	mat.angular_velocity_max = rotate_speed

	mat.turbulence_enabled = swirl > 0.0
	mat.turbulence_noise_strength = 0.6
	mat.turbulence_noise_scale = 4.0
	mat.turbulence_influence_min = swirl * 0.02
	mat.turbulence_influence_max = swirl * 0.08

	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(emit_width * 0.5, 4.0, 1.0)

	# Random frame from the 3-leaf strip; anim stays on that frame.
	mat.anim_offset_min = 0.0
	mat.anim_offset_max = 1.0

	# Keep the whole fall path visible regardless of tuning.
	var fall_dist := fall_speed * lifetime + 0.5 * (fall_speed * 0.3) * lifetime * lifetime
	var half_w := emit_width * 0.5 + absf(wind) * lifetime * lifetime * 0.5 + 64.0
	visibility_rect = Rect2(-half_w, -32.0, half_w * 2.0, fall_dist + 96.0)
