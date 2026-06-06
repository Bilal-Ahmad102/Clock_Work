## PlayerData.gd
## Autoload singleton — all LimboStates read/write shared player values here.
## Add to Project > Project Settings > Autoload as "PlayerData"
extends Node

# ── Movement config ──────────────────────────────────────────
const WALK_SPEED       := 175.0
const RUN_SPEED        := 350.0
const ACCELERATION     := 1800.0
const DECELERATION     := 2200.0
const AIR_CONTROL      := 0.6
# ── Jump config ──────────────────────────────────────────────
const JUMP_VELOCITY         := -520.0
const JUMP_HOLD_GRAV_SCALE  := 1.15
const FALL_GRAV_SCALE       := 1.6
const COYOTE_TIME           := 0.08
const JUMP_BUFFER_TIME      := 0.10
# ── Dash config ─────────────────────────────────────────────
const DASH_SPEED         := 600.0
const DASH_DURATION      := 0.3
const DASH_STAMINA_COST  := 20.0
const INV_FRAMES         := 8

# ── Magic Dash config ─────────────────────────────────────────────
const MAGIC_DASH_SPEED         := 2500.0
const MAGIC_DASH_DURATION      := 0.1
const MAGIC_DASH_MANA_COST  := 40.0
const MAGIC_INV_FRAMES         := 8

# ── Magic Dash config ─────────────────────────────────────────────
const MAGIC_HEAVY_ATTACK_MANA_COST  := 50.0

# ── Stamina config ───────────────────────────────────────────
const MAX_STAMINA         := 100.0
const STAMINA_REGEN_RATE  := 12.0
const STAMINA_REGEN_DELAY := 1.2

# ── Health config ───────────────────────────────────────────
const MAX_HEALTH         := 100.0
const HEALTH_REGEN_RATE  := 12.0
const HEALTH_REGEN_DELAY := 1.2

# ── Mana config ──────────────────────────────────────────────
const MAX_MANA         := 100.0
const MANA_REGEN_RATE  := 5.0     # per second ; slower than stamina
const MANA_REGEN_DELAY := 3.0     # seconds before regen starts ; longer delay



# ── Attacks Damage ──────────────────────────────────────────────
const LIGHT_ATTACK_DAMAGE_COMBO_1  := 8.0
const LIGHT_ATTACK_DAMAGE_COMBO_2  := 10.0
const LIGHT_ATTACK_DAMAGE_COMBO_3  := 15.0

const SPRINT_ATTACK_DAMAGE  := 10.0

const HEAVY_ATTACK_DAMAGE  := 32.0
const MAGIC_HEAVY_ATTACK_DAMAGE  := 60.0


# ── Runtime state ────────────────────────────────────────────
var stamina            : float = MAX_STAMINA
var mana               : float = MAX_MANA
var health             : float = MAX_HEALTH

var stamina_regen_timer: float = 0.0
var mana_regen_timer   : float = 0.0
var health_regen_timer   : float = 0.0

var is_invincible      : bool  = false
var invincibility_timer: float = 0.0
var coyote_timer       : float = 0.0
var jump_buffer_timer  : float = 0.0
var was_on_floor       : bool  = false
var dash_direction     : float = 1.0
var movement_locked    : bool  = false


# ── Signals ──────────────────────────────────────────────────
signal stamina_changed(current: float, maximum: float)
signal mana_changed(current: float, maximum: float)
signal health_changed(current: float, maximum: float)

signal dash_started
signal dash_ended

signal magic_dash_atk_started
signal magic_dash_atk_ended

signal landed

# ── Stamina helpers ───────────────────────────────────────────
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
# ── Mana helpers ──────────────────────────────────────────────
func spend_mana(amount: float) -> void:
	mana = max(0.0, mana - amount)
	mana_regen_timer = MANA_REGEN_DELAY
	mana_changed.emit(mana, MAX_MANA)

func try_spend_mana(amount: float) -> bool:
	if mana >= amount:
		spend_mana(amount)
		return true
	return false

func regen_mana(delta: float) -> void:
	if mana >= MAX_MANA:
		return
	if mana_regen_timer > 0.0:
		mana_regen_timer -= delta
		return
	mana = min(MAX_MANA, mana + MANA_REGEN_RATE * delta)
	mana_changed.emit(mana, MAX_MANA)
# ── Tick helpers ──────────────────────────────────────────────
func tick_invincibility(delta: float) -> void:
	if invincibility_timer > 0.0:
		invincibility_timer -= delta
		is_invincible = invincibility_timer > 0.0
