extends Node
# Autoload: Captain
# Stateful vessel. Holds the four metrics for the active Captain role.
# Holds no memory. Does not decide its own recast or pick its vessel.
# Form is the combat HP pool. Volatility drives erratic AI behavior.

signal form_collapsed
signal recast_applied(recast_count: int)
signal metrics_changed
signal true_death(role: StringName)

var role            : StringName = &""
var recast_count    : int   = 0

var poise           : float = 100.0   # mental stability
var form            : float = 100.0   # physical body, combat depletes this
var role_integrity  : float = 100.0   # role coherence after recasts
var audience_favor  : float = 100.0   # how much the Audience wants this role on stage
var volatility      : float = 0.0     # erratic behavior multiplier, rises per scar

const MAX_RECASTS          : int = 5
var available_vessels      : Array[StringName] = []
var attaking_vessel        : CharacterBody2D = null

const SCAR_POISE_LOSS      : float = 15.0
const SCAR_INTEGRITY_LOSS  : float = 10.0
const SCAR_VOLATILITY_GAIN : float = 20.0

func is_active() -> bool:
	return role != &"" and form > 0.0

# Spawn a fresh role onto the stage
func bind_role(new_role: StringName, vessels: Array[StringName]) -> void:
	role              = new_role
	available_vessels = vessels
	recast_count      = 0
	poise             = 100.0
	form              = 100.0
	role_integrity    = 100.0
	audience_favor    = 100.0
	volatility        = 0.0
	Audience.register_role(new_role)
	metrics_changed.emit()

# Combat damage hits Form only
func take_damage(amount: float) -> void:
	form = clamp(form - amount, 0.0, 100.0)
	metrics_changed.emit()
	if form <= 0.0:
		form_collapsed.emit()
		_on_form_collapse()

func _on_form_collapse() -> void:
	# Audience enforces continuation unless the role is invalidated
	apply_role_scar()
	if check_role_invalidation():
		Audience.invalidate_role(role)
		true_death.emit(role)
		role = &""
	else:
		_recast_into_new_vessel()

func apply_role_scar() -> void:
	recast_count   += 1
	poise           = clamp(poise          - SCAR_POISE_LOSS,      0.0, 100.0)
	role_integrity  = clamp(role_integrity - SCAR_INTEGRITY_LOSS,  0.0, 100.0)
	volatility      = clamp(volatility     + SCAR_VOLATILITY_GAIN, 0.0, 100.0)
			
func check_role_invalidation() -> bool:
	var repeated_role_breaks : bool = recast_count >= MAX_RECASTS
	var audience_abandoned   : bool = audience_favor <= 0.0
	var no_viable_vessels    : bool = recast_count >= available_vessels.size()
	#var narrative_refused    : bool = PlayerData.path_state == &"REJECTION" and role_integrity <= 0.0
	return repeated_role_breaks or audience_abandoned or no_viable_vessels #or narrative_refused

func _recast_into_new_vessel() -> void:
	form = 100.0   # new body, full Form. Poise and Integrity stay scarred.
	recast_applied.emit(recast_count)
	metrics_changed.emit()

# Pressure entry points called by the Audience
func pressure_poise(amount: float) -> void:
	poise = clamp(poise + amount, 0.0, 100.0)
	metrics_changed.emit()

func pressure_integrity(amount: float) -> void:
	role_integrity = clamp(role_integrity + amount, 0.0, 100.0)
	metrics_changed.emit()

func pressure_favor(amount: float) -> void:
	print("favor amount : ", amount)
	audience_favor = clamp(audience_favor + amount, 0.0, 100.0)
	metrics_changed.emit()

func damage_back_attacking_vessel(amount:int):
	if attaking_vessel:
		print("TAKE DAMAGE ",amount)
		attaking_vessel.take_damage(amount)
