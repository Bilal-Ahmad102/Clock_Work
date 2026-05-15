extends CharacterBody2D

@onready var collision: CollisionShape2D  = $CollisionShape2D
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var fx_player: AnimatedSprite2D = %FX_player

var facing_left : bool = false

func _physics_process(delta: float) -> void:
	# Global systems that run regardless of state
	PlayerData.regen_stamina(delta)
	PlayerData.tick_invincibility(delta)
	_tick_coyote(delta)
	_tick_jump_buffer(delta)

	# Let the active state modify velocity, then move
	move_and_slide()

	# Track floor for coyote time
	var on_floor_now := is_on_floor()
	if not PlayerData.was_on_floor and on_floor_now:
		PlayerData.landed.emit()
	PlayerData.was_on_floor = on_floor_now

# ── Gravity (called by airborne states) ──────────────────────
func apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	var scale: float
	if velocity.y < 0.0 and Input.is_action_pressed("jump"):
		scale = PlayerData.JUMP_HOLD_GRAV_SCALE
	else:
		scale = PlayerData.FALL_GRAV_SCALE
	velocity.y += get_gravity().y * scale * delta

# ── Horizontal movement (called by ground + air states) ──────
func apply_horizontal(delta: float, speed: float) -> void:
	var dir := Input.get_axis("move_left", "move_right")
	var control := 1.0 #if is_on_floor() else PlayerData.AIR_CONTROL
	
	if dir != 0.0 :
		sprite.flip_h = dir < 0.0
		facing_left = sprite.flip_h 
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
		

func play_anim_then_loop(anim: StringName, transition_frame: int = 0, end_frame: int = 0) -> void:
	if !sprite: sprite = get_node("AnimatedSprite2D")
	if sprite.animation != anim:
		sprite.play(anim)
		if !sprite.frame_changed.is_connected(_on_transition_frame_changed):
			sprite.frame_changed.connect(_on_transition_frame_changed.bind(anim, transition_frame, end_frame))

func _on_transition_frame_changed(anim: StringName, transition_frame: int, end_frame: int) -> void:
	if sprite.frame >= transition_frame:
		sprite.frame_changed.disconnect(_on_transition_frame_changed)
		play_anim_looped(anim, transition_frame, end_frame)

func play_anim_looped(anim: StringName, start_frame: int, end_frame: int) -> void:
	sprite.frame = start_frame
	play_anim(anim, start_frame)
	if !sprite.frame_changed.is_connected(_on_frame_changed):
		sprite.frame_changed.connect(_on_frame_changed.bind(start_frame, end_frame))

func _on_frame_changed(start_frame: int, end_frame: int) -> void:
	if sprite.frame >= end_frame:
		sprite.frame = start_frame

func play_anim_rest(anim: StringName, _start_frame: int) -> void:
	if sprite.frame_changed.is_connected(_on_frame_changed):
		sprite.frame_changed.disconnect(_on_frame_changed)
	sprite.frame = _start_frame
	sprite.play(anim)
	print(sprite.animation)

#endregion Animation Helper Functions


# ── Coyote / jump-buffer ticks ───────────────────────────────
func _tick_coyote(delta: float) -> void:
	if PlayerData.was_on_floor and not is_on_floor():
		PlayerData.coyote_timer = PlayerData.COYOTE_TIME
	if PlayerData.coyote_timer > 0.0:
		PlayerData.coyote_timer -= delta

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
	
