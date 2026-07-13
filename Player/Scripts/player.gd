extends CharacterBody2D


@export var check_point : Marker2D

@export_group("Camera")
## Screen-space offset from the player; negative y frames the view higher.
@export var cam_offset := Vector2(0, -40)
## Catch-up rate per axis; higher = stiffer, ~0 = frozen.
@export var cam_damping := Vector2(6.0, 4.0)
## 0 = raw damped follow; toward 1 adds a soft second smoothing pass.
@export_range(0.0, 1.0) var cam_smoothing := 0.15
## Half-size of the box the player can roam before the camera follows.
@export var cam_deadzone := Vector2(24.0, 32.0)
@export_subgroup("Lookahead")
## Pixels the camera leads in the direction of travel.
@export var cam_lookahead := 60.0
@export var cam_lookahead_speed := 2.5
## Extra downward look while falling faster than the threshold.
@export var cam_fall_lookdown := 50.0
@export var cam_fall_speed_threshold := 200.0
@export_subgroup("Limits")
@export var cam_limit_left := -10000000
@export var cam_limit_top := -10000000
@export var cam_limit_right := 10000000
@export var cam_limit_bottom := 10000000
@export_group("")

@onready var collision: CollisionShape2D  = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_machine: LimboHSM = $state_machine
@onready var hitbox: Area2D = %hitbox
@onready var chest_ray: RayCast2D = %chest_ray
@onready var head_ray: RayCast2D = %head_ray

@onready var fx_player: AnimatedSprite2D = %FX_player
@onready var ui: CanvasLayer = $UI
@onready var raycasts: Node2D = $Raycasts
@onready var camera: PlayerCamera = $PlayerCamera

var facing_left : bool = false
var is_falling  : bool = false

func _ready() -> void:
	ui.show()
	_configure_camera()

## Pushes the exported Camera-group values into the follow camera.
## Re-call after changing any cam_* value at runtime.
func _configure_camera() -> void:
	camera.target = self
	camera.follow_offset = cam_offset
	camera.damping = cam_damping
	camera.smoothing = cam_smoothing
	camera.deadzone = cam_deadzone
	camera.lookahead = cam_lookahead
	camera.lookahead_speed = cam_lookahead_speed
	camera.fall_lookdown = cam_fall_lookdown
	camera.fall_speed_threshold = cam_fall_speed_threshold
	camera.set_base_limits(cam_limit_left, cam_limit_top, cam_limit_right, cam_limit_bottom)
	camera.make_current()
	camera.snap_to_target()

func _physics_process(delta: float) -> void:
	# Global systems that run regardless of state
	PlayerData.regen_stamina(delta)
	PlayerData.regen_mana(delta)
	PlayerData.tick_invincibility(delta)

	_tick_coyote(delta)
	_tick_jump_buffer(delta)
	var can_grab = _check_ledge_grab()
	%debug2.text = "True" if can_grab else "false"

	if !is_falling and !is_on_floor() :
		state_machine.dispatch(&"fall")

	move_and_slide()


# ── Gravity (called by airborne states) ──────────────────────
func apply_gravity(delta: float) -> void:
	if is_on_floor() or PlayerData.movement_locked:
		return

	var _scale: float
	if velocity.y < 0.0 and Input.is_action_pressed("jump"):
		_scale = PlayerData.JUMP_HOLD_GRAV_SCALE
	else:
		_scale = PlayerData.FALL_GRAV_SCALE
	velocity.y += get_gravity().y * _scale * delta

# ── Horizontal movement (called by ground + air states) ──────
func apply_horizontal(delta: float, speed: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	var control := 1.0 #if is_on_floor() else PlayerData.AIR_CONTROL
	
	if dir != 0.0 :
		sprite.flip_h = dir < 0.0
		facing_left = sprite.flip_h 
		hitbox.change_face(facing_left)
		raycasts.flip_rays(facing_left)
		velocity.x = move_toward(
			velocity.x,
			dir * speed,
			PlayerData.ACCELERATION * control * delta
		)
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			PlayerData.DECELERATION * control * delta
		)

# ── Animation helper ─────────────────────────────────────────


#region Animation Helper Functions
func play_anim(anim: StringName, start_frame: int = 0) -> void:
	if !sprite: sprite = get_node("AnimatedSprite2D")
	if sprite.animation != anim:
		sprite.frame = start_frame
		sprite.play(anim)


#endregion Animation Helper Functions

# Edge Grab Functions
func _check_ledge_grab() -> bool:
	if is_on_floor() or not is_on_wall():
		return false
	var chest_hit = chest_ray.is_colliding()
	var head_clear = not head_ray.is_colliding()
	var moving_toward_wall = (velocity.x > 0 and !facing_left) or (velocity.x < 0 and facing_left)
	return chest_hit and head_clear and moving_toward_wall

# ── Coyote / jump-buffer ticks ───────────────────────────────
func _tick_coyote(delta: float) -> void:
	var on_floor_now := is_on_floor()
	if PlayerData.was_on_floor and not on_floor_now:
		PlayerData.coyote_timer = PlayerData.COYOTE_TIME
	if PlayerData.coyote_timer > 0.0:
		PlayerData.coyote_timer -= delta

	# Track floor for coyote time
	if not PlayerData.was_on_floor and on_floor_now:
		PlayerData.landed.emit()
	PlayerData.was_on_floor = on_floor_now

func _tick_jump_buffer(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		PlayerData.jump_buffer_timer = PlayerData.JUMP_BUFFER_TIME
	if PlayerData.jump_buffer_timer > 0.0:
		PlayerData.jump_buffer_timer -= delta

# ── Public helpers called by combat script ───────────────────
func set_movement_locked(locked: bool) -> void:
	PlayerData.movement_locked = locked

func full_stop_movement(value :bool ):
	if value:
		velocity = Vector2.ZERO

func take_damage(amount: float):
	match state_machine.get_active_state():
		state_machine.shield_block:
			if !%shield_block.block_attack():
				state_machine.dispatch(&"hurt")
				PlayerData.take_damage(amount)
		_:
			state_machine.dispatch(&"hurt")
			PlayerData.take_damage(amount)

func take_health():
	PlayerData.health -= 10

func give_parry_window():
	if state_machine.get_active_state() == state_machine.parry:
		if %parry.do_parry():
			Captain.damage_back_attacking_vessel(5)
func set_checkpoint(point:Marker2D):
	check_point = point
func die():
	self.global_position = check_point.global_position
