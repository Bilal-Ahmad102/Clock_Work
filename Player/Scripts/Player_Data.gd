## PlayerData.gd
## Autoload singleton — all LimboStates read/write shared player values here.
## Add to Project > Project Settings > Autoload as "PlayerData"
extends Node

# ── Movement config ──────────────────────────────────────────
const WALK_SPEED       := 175.0   # 3.5 m/s  (50 px = 1 m)
const RUN_SPEED        := 350.0   # 7.0 m/s
const ACCELERATION     := 1800.0
const DECELERATION     := 2200.0
const AIR_CONTROL      := 0.6     # 60 % of ground accel in air

# ── Jump config ──────────────────────────────────────────────
const JUMP_VELOCITY         := -520.0
const JUMP_HOLD_GRAV_SCALE  := 0.55   # hold = floatier rise
const FALL_GRAV_SCALE       := 1.6    # snappy fall
const COYOTE_TIME           := 0.08   # 80 ms
const JUMP_BUFFER_TIME      := 0.10   # 100 ms

# ── Dodge config ─────────────────────────────────────────────
const DASH_SPEED         := 600.0
const DASH_DURATION      := 0.3   # seconds
const DASH_STAMINA_COST  := 20.0
const INV_FRAMES          := 8       # at 60 fps ≈ 0.13 s

# ── Stamina config ───────────────────────────────────────────
const MAX_STAMINA         := 100.0
const STAMINA_REGEN_RATE  := 12.0    # per second
const STAMINA_REGEN_DELAY := 1.2     # seconds before regen starts

# ── Runtime state (written by states, read by others) ────────
var stamina            : float = MAX_STAMINA
var stamina_regen_timer: float = 0.0
var is_invincible      : bool  = false
var invincibility_timer: float = 0.0
var coyote_timer       : float = 0.0
var jump_buffer_timer  : float = 0.0
var was_on_floor       : bool  = false
var dash_direction    : float = 1.0
var movement_locked    : bool  = false   # set true during attack anims

# ── Signals ──────────────────────────────────────────────────
signal stamina_changed(current: float, maximum: float)
signal dash_started
signal dash_ended
signal landed

# ── Stamina helpers (called by any state) ────────────────────
func spend_stamina(amount: float) -> void:
	stamina = max(0.0, stamina - amount)
	stamina_regen_timer = STAMINA_REGEN_DELAY
	stamina_changed.emit(stamina, MAX_STAMINA)

func try_spend_stamina(amount: float) -> bool:
	if stamina >= amount:
		spend_stamina(amount)
		return true
	return false

func regen_stamina(delta: float) -> void:
	if stamina >= MAX_STAMINA:
		return
	if stamina_regen_timer > 0.0:
		stamina_regen_timer -= delta
		return
	stamina = min(MAX_STAMINA, stamina + STAMINA_REGEN_RATE * delta)
	stamina_changed.emit(stamina, MAX_STAMINA)

func tick_invincibility(delta: float) -> void:
	if invincibility_timer > 0.0:
		invincibility_timer -= delta
		is_invincible = invincibility_timer > 0.0
