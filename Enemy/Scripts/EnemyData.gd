extends Node

const MAX_HP           := 100.0
const MOVE_SPEED       := 4.2 * 50.0   # 4.2 m/s in pixels
const ATTACK_COOLDOWN  := 1.8
const STAGGER_DURATION := 0.6
const RECOVER_DURATION := 0.4
const LIGHT_DAMAGE     := 12.0
const HEAVY_DAMAGE     := 28.0

# Dominance tracking ; mirrors Marla's combat style
var authority_score: int = 0   # increments on each Marla aggressive action
var resolve_score:   int = 0   # increments on each Marla defensive action

# Current cast role
enum CastRole { NEUTRAL, AGGRESSIVE, DEFENSIVE }
var current_role: CastRole = CastRole.NEUTRAL

func register_marla_attack() -> void:
	authority_score += 1
	_recalculate_role()

func register_marla_block() -> void:
	resolve_score += 1
	_recalculate_role()

func register_marla_parry() -> void:
	resolve_score += 2  # parry counts more than block
	_recalculate_role()

func _recalculate_role() -> void:
	var diff := authority_score - resolve_score
	if diff > 3:
		current_role = CastRole.DEFENSIVE
	elif diff < -3:
		current_role = CastRole.AGGRESSIVE
	else:
		current_role = CastRole.NEUTRAL

func reset_scores() -> void:
	authority_score = 0
	resolve_score   = 0
	current_role    = CastRole.NEUTRAL
