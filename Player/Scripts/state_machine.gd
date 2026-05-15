extends LimboHSM

'''================= States ======================='''

@onready var idle: LimboState = $idle
@onready var run: LimboState = $run
@onready var walk: LimboState = $walk
@onready var jump: LimboState = $jump
@onready var land: LimboState = $land
@onready var fall: LimboState = $fall
@onready var dash: LimboState = $dash
@onready var sprint_atk: LimboState = $sprint_atk
@onready var combo_atk: LimboState = $combo_atk
@onready var shield_block: LimboState = $shield_block
@onready var parry: LimboState = $parry

@onready var heavy_atk: LimboState = $heavy_atk

'''================= States ======================='''


var previous_state : LimboState 
var movement_states : Array[LimboState]

var shield_hold_time := 0.0
const SHIELD_HOLD_THRESHOLD := 0.2 # seconds

var state_to_states_transition : Dictionary 
var state_to_input_functions : Dictionary 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_state_to_states_dictionary()
	fill_state_to_input_functions()
	_init_state_machine_()
	movement_states = [idle,walk,run]
	
	if not agent.sprite.animation_finished.is_connected(_on_animation_finished):
		agent.sprite.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	if get_active_state().has_method("_on_animation_finished"):
		get_active_state()._on_animation_finished()
	else:
		push_error("State does not has animation finished function.")


func fill_state_to_states_dictionary() -> void:
	state_to_states_transition = {
		idle:        [run, walk, dash, fall, combo_atk, heavy_atk, shield_block,parry],
		walk:        [run, dash, fall, combo_atk, heavy_atk, shield_block,parry],
		run:         [jump, run, dash, fall, sprint_atk,parry],
		jump:        [dash, fall],
		land:        [run, walk, dash, fall],
		fall:        [land],
		dash:        [run, walk, fall],
		combo_atk:   [walk,idle],
		sprint_atk:  [run],
		shield_block:[parry],
		heavy_atk:   [],
	}
func fill_state_to_input_functions() -> void:
	state_to_input_functions = {
		idle:        [input_for_run,input_for_parry,input_for_walk, input_for_heavy_atk, input_for_combo_light_atk, input_for_shield_block,input_for_dash],
		walk:        [input_for_run,input_for_parry,input_for_heavy_atk, input_for_dash,input_for_combo_light_atk, input_for_shield_block,input_for_idle],
		run:         [input_for_sprint_atk,input_for_parry,input_for_jump,input_for_dash,input_for_idle],
		jump:        [],
		land:        [],
		fall:        [],
		dash:        [],
		combo_atk:   [input_for_walk],
		sprint_atk:  [],
		shield_block:[input_for_parry],
		heavy_atk:   [],
		parry:       []
	}
func _init_state_machine_():
	initial_state = idle
	previous_state = idle
	_init_transitions()
	initialize(get_parent())
	set_active(true)
	
func _init_transitions() -> void:
	add_transition(ANYSTATE, idle, &"idle")
	for from_state in state_to_states_transition:
		for to_state in state_to_states_transition[from_state]:
			add_transition(from_state, to_state, _get_event(to_state))

func _get_event(to_state: LimboState) -> StringName:
	if to_state == idle:        return &"idle"
	if to_state == walk:        return &"walk"
	if to_state == run:         return &"run"
	if to_state == jump:        return &"jump"
	if to_state == land:        return &"land"
	if to_state == fall:        return &"fall"
	if to_state == dash:        return &"dash"
	if to_state == combo_atk:   return &"combo_atk"
	if to_state == sprint_atk:  return &"sprint_atk"
	if to_state == shield_block:return &"shield_block"
	if to_state == heavy_atk:   return &"heavy_atk"
	if to_state == parry:   return &"parry"
	
	push_error("No event found for state: " + to_state.name)
	return &""


var _dispatched_this_frame: bool = false

func _update(delta: float) -> void:
	_dispatched_this_frame = false
	var active := get_active_state()
	if state_to_input_functions.has(active):
		for input_func in state_to_input_functions[active]:
			input_func.call()
			if _dispatched_this_frame:
				break

func _dispatch(event: StringName) -> void:
	_dispatched_this_frame = true
	dispatch(event)
#region Inputs 
func input_for_sprint_atk():
	if Input.is_action_just_pressed("sprint_attack"):
		_dispatch(&"sprint_atk")

func input_for_heavy_atk():
	if Input.is_action_just_pressed("heavy_atk"):
		_dispatch(&"heavy_atk")

func input_for_run():
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		if Input.is_action_pressed("run"):
			_dispatch(&"run")

func input_for_idle():
	var dir := Input.get_axis("move_left", "move_right")
	if dir == 0.0:
		_dispatch(&"idle")

func input_for_walk():
	if get_active_state() ==  combo_atk and !combo_atk.can_check_for_walk :
		return
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		_dispatch(&"walk")
		
func input_for_jump():
	if PlayerData.jump_buffer_timer > 0.0 or Input.is_action_just_pressed("jump"):
		_dispatch(&"jump")


func input_for_dash():
	if Input.is_action_just_pressed("dash") \
			and PlayerData.stamina >= PlayerData.DASH_STAMINA_COST:
		_dispatch(&"dash")

func input_for_combo_light_atk():
	if Input.is_action_just_pressed("combo_atk"):
		_dispatch(&"combo_atk")



func input_for_parry():
	if Input.is_action_just_pressed("parry"):
		_dispatch(&"parry")

func input_for_shield_block() -> bool:
	if Input.is_action_pressed("shield_block"):
		shield_hold_time += get_process_delta_time()
		if shield_hold_time >= SHIELD_HOLD_THRESHOLD:
			if get_active_state() != shield_block:
				_dispatch(&"shield_block")
			return true
		return false
	else:
		shield_hold_time = 0.0
		if get_active_state() == shield_block:
			return false
	return false
#endregion Inputs 
