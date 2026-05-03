extends LimboHSM

'''================= States ======================='''

@onready var idle: LimboState = $idle
@onready var run: LimboState = $run
@onready var walk: LimboState = $walk
@onready var jump: LimboState = $jump
@onready var land: LimboState = $land
@onready var fall: LimboState = $fall
@onready var dash: LimboState = $dash

'''================= States ======================='''


var previous_state : LimboState 
var movement_states : Array[LimboState]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_state_machine_()
	movement_states = [idle,walk,run]
	
	if not agent.sprite.animation_finished.is_connected(_on_animation_finished):
		agent.sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished() -> String:
	return agent.sprite.animation
 
func _init_state_machine_():
	initial_state = idle
	previous_state = idle
	_init_transitions()
	initialize(get_parent())
	set_active(true)

func _init_transitions():
	add_transition(ANYSTATE, idle , &"idle")

	add_transition(run,  jump,   &"jump")
	add_transition(fall,  land,   &"land")

	for state in [idle,land,walk,dash]:
		add_transition(state,  run,   &"run")

	for state in [idle,run,land,dash]:
		add_transition(state,  walk,   &"walk")

	for state in [idle,run,walk,jump]:
		add_transition(state,  dash,   &"dash")

	for state in [idle,run,walk,jump,dash]:
		add_transition(state,  fall,   &"fall")
