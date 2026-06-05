# state_machine.gd
extends LimboHSM

#region States
@onready var idle:    LimboState = $idle
@onready var chase:   LimboState = $chase
@onready var attack:  LimboState = $attack
@onready var stagger: LimboState = $stagger
@onready var recover: LimboState = $recover
@onready var recast:  LimboState = $recast
#endregion

var previous_state: LimboState
var state_to_states_transition: Dictionary

func _ready() -> void:
	fill_state_to_states_dictionary()
	_init_state_machine()
	if not agent.sprite.animation_finished.is_connected(_on_animation_finished):
		agent.sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> void:
	if get_active_state().has_method("_on_animation_finished"):
		get_active_state()._on_animation_finished()

func fill_state_to_states_dictionary() -> void:
	state_to_states_transition = {
		idle:    [chase,recast],
		chase:   [attack, idle, stagger,recast],
		attack:  [stagger, recover,recast],
		stagger: [recover,recast],
		recover: [chase, idle,recast],
		recast:  [idle],
	}

func _init_state_machine() -> void:
	initial_state  = idle
	previous_state = idle
	_init_transitions()
	initialize(get_parent())
	set_active(true)

func _update(delta: float) -> void:
	%debug.text = str(get_active_state().name)

func _init_transitions() -> void:
	for from_state in state_to_states_transition:
		for to_state in state_to_states_transition[from_state]:
			add_transition(from_state, to_state, _get_event(to_state))

func _get_event(to_state: LimboState) -> StringName:
	if to_state == idle:    return &"idle"
	if to_state == chase:   return &"chase"
	if to_state == attack:  return &"attack"
	if to_state == stagger: return &"stagger"
	if to_state == recover: return &"recover"
	if to_state == recast:  return &"recast"
	push_error("No event found for state: " + to_state.name)
	return &""
