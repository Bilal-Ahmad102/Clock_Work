extends Node
# Autoload: Audience
# Persistent memory layer. Records Marla's behavior across all encounters
# and applies that recorded pressure onto the active Captain's metrics.
# The Captain holds no memory. The Audience is the only thing that remembers.

signal favor_shifted(captain_favor: float)
signal role_invalidated(role: StringName)
signal world_absence(failed_roles: Array)

const REPEAT_WINDOW : int = 6
var _recent_ids : Array[StringName] = []

# Marla behavioral patterns. Accumulate across encounters, never reset per fight.
var brutality   : float = 0.0
var restraint   : float = 0.0
var precision   : float = 0.0
var hesitation  : float = 0.0
var repetition  : float = 0.0


# Cast registry
var active_cast  : Array[StringName] = []
var failed_roles : Array[StringName] = []

# How hard accumulated patterns push on Captain metrics each pressure tick
const PRESSURE_INTERVAL   : float = 1.0    # seconds between pressure applications
const BRUTALITY_TO_POISE  : float = 0.04   # brutal play erodes Captain mental stability
const PRECISION_TO_INTEG  : float = 0.03   # clean precise play erodes role coherence
const REPETITION_TO_FAVOR : float = 0.05   # repetitive play bleeds Audience Favor
const RESTRAINT_TO_FAVOR  : float = 0.02   # restrained play preserves favor slightly
const HESITATION_TO_POISE : float = 0.02   # her hesitation steadies the role a touch

var _pressure_timer : float = 0.0

#func _process(delta: float) -> void:
	#_pressure_timer += delta
	#if _pressure_timer >= PRESSURE_INTERVAL:
		#_pressure_timer = 0.0
		#_apply_pressure_to_captain()

# Recording Marla's behavior. Call these from her combat verbs.
func record_brutal_hit(amount: float = 1.0) -> void:
	brutality = clamp(brutality + amount, 0.0, 100.0)
	repetition = clamp(repetition + (amount * 0.33), 0.0, 100.0)

func record_precise_hit(amount: float) -> void:
	precision = clamp(precision + amount, 0.0, 100.0)


func record_restrained_action() -> void:
	restraint = clamp(restraint + 1.0, 0.0, 100.0)
	
func record_hesitation() -> void:
	hesitation = clamp(hesitation + 1.0, 0.0, 100.0)


func record_repeat_attack(attack_id: StringName) -> void:
	_recent_ids.append(attack_id)
	if _recent_ids.size() > REPEAT_WINDOW:
		_recent_ids.pop_front()

	var same := 0
	for id in _recent_ids:
		if id == attack_id:
			same += 1
	if same >= 3:
		repetition = clamp(repetition + 1.0, 0.0, 100.0)

# Pushes accumulated Marla patterns onto the active Captain.
# This is the core of the clarification: memory affects Captain metrics directly.
func _apply_pressure_to_captain() -> void:
	print("APPLY PRessure")
	if not Captain.is_active():
		print("APPLY PRessure end")
		return
	Captain.pressure_poise(-brutality * BRUTALITY_TO_POISE)
	Captain.pressure_poise(hesitation * HESITATION_TO_POISE)
	Captain.pressure_integrity(-precision * PRECISION_TO_INTEG)
	Captain.pressure_favor(-repetition * REPETITION_TO_FAVOR)
	Captain.pressure_favor(restraint * RESTRAINT_TO_FAVOR)

	favor_shifted.emit(Captain.audience_favor)

# Cast lifecycle
func register_role(role: StringName) -> void:
	if not active_cast.has(role):
		active_cast.append(role)

func invalidate_role(role: StringName) -> void:
	active_cast.erase(role)
	if not failed_roles.has(role):
		failed_roles.append(role)
	role_invalidated.emit(role)
	world_absence.emit(failed_roles)

func reset_session() -> void:
	# clears only Cast state, never the behavioral memory
	active_cast.clear()
