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
@onready var idle_jump: LimboState = $idle_jump
@onready var edge_grab: LimboState = $edge_grab
@onready var hurt: LimboState = $hurt

@onready var magic_dash_atk: LimboState = $magic_dash_atk
@onready var magic_heavy_atk: LimboState = $magic_heavy_atk
'''================= States ======================='''


@onready var chest_ray: RayCast2D = %chest_ray
@onready var head_ray: RayCast2D = %head_ray


var previous_state : LimboState 
var movement_states : Array[LimboState]

var shield_hold_time := 0.0
const SHIELD_HOLD_THRESHOLD := 0.2 # seconds

var state_to_states_transition : Dictionary 
var grabbed_edge : StaticBody2D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fill_state_to_states_dictionary()
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
		idle:             [run, walk, dash, fall, idle_jump,hurt, combo_atk, 
						   heavy_atk, shield_block,parry,magic_dash_atk,magic_heavy_atk],
		walk:             [run, dash,idle_jump, fall, hurt,combo_atk, heavy_atk, shield_block,parry],
		run:              [jump, run, dash, fall,hurt, sprint_atk,parry],
		jump:             [dash, hurt,fall],
		land:             [run, walk, dash, fall],
		fall:             [land,hurt,edge_grab],
		dash:             [run, walk, fall],
		combo_atk:        [walk,idle],
		sprint_atk:       [run],
		shield_block:     [parry],
		heavy_atk:        [walk,idle],
		parry :           [shield_block],
		magic_dash_atk:   [idle],
		magic_heavy_atk:  [idle],
		idle_jump:        [idle,hurt,edge_grab],
		edge_grab:        [idle,hurt],
		hurt:             [idle]
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
	if to_state == idle:             return &"idle"
	if to_state == walk:             return &"walk"
	if to_state == run:              return &"run"
	if to_state == jump:             return &"jump"
	if to_state == land:             return &"land"
	if to_state == fall:             return &"fall"
	if to_state == dash:             return &"dash"
	if to_state == combo_atk:        return &"combo_atk"
	if to_state == sprint_atk:       return &"sprint_atk"
	if to_state == shield_block:     return &"shield_block"
	if to_state == heavy_atk:        return &"heavy_atk"
	if to_state == parry:            return &"parry"
	if to_state == magic_dash_atk:   return &"magic_dash_atk"
	if to_state == magic_heavy_atk:  return &"magic_heavy_atk"
	if to_state == idle_jump:        return &"idle_jump"
	if to_state == edge_grab:        return &"edge_grab"
	if to_state == hurt:             return &"hurt"
	
	push_error("No event found for state: " + to_state.name)
	return &""



#region Inputs 
func input_for_sprint_atk():
	if Input.is_action_just_pressed("sprint_attack"):
		dispatch(&"sprint_atk")

func input_for_heavy_atk():
	if Input.is_action_just_pressed("heavy_atk") and !Input.is_action_pressed("magic"):
		dispatch(&"heavy_atk")

func input_for_run():
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		if Input.is_action_pressed("run"):
			dispatch(&"run")

func input_for_idle():
	var dir := Input.get_axis("move_left", "move_right")
	if dir == 0.0:
		dispatch(&"idle")

func input_for_walk():
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		dispatch(&"walk")
		return true
	else: return false

func input_for_jump():
	if PlayerData.jump_buffer_timer > 0.0 or Input.is_action_just_pressed("jump"):
		if get_active_state() == idle or get_active_state() == walk :
			dispatch(&"idle_jump")
		else:
			dispatch(&"jump")

func check_for_edge_grab():
	if chest_ray.is_colliding() and !head_ray.is_colliding():
		print(chest_ray.get_collider())
		if !chest_ray.get_collider().is_in_group("Grabable_Edges"): return
		grabbed_edge = chest_ray.get_collider()
		dispatch(&"edge_grab")
		
func input_for_dash():
	if Input.is_action_just_pressed("dash") and !Input.is_action_pressed("magic")\
			and PlayerData.stamina >= PlayerData.DASH_STAMINA_COST:
		dispatch(&"dash")
func input_for_magic_dash_atk():
	if Input.is_action_just_pressed("dash")  and Input.is_action_pressed("magic")\
			and PlayerData.mana >= PlayerData.MAGIC_DASH_MANA_COST:
		dispatch(&"magic_dash_atk")

func input_for_heavy_dash_atk():
	if Input.is_action_just_pressed("heavy_atk") and Input.is_action_pressed("magic")\
			and PlayerData.mana >= PlayerData.MAGIC_HEAVY_ATTACK_MANA_COST:
		dispatch(&"magic_heavy_atk")

func input_for_combo_light_atk():
	if Input.is_action_just_pressed("combo_atk"):
		dispatch(&"combo_atk")



func input_for_parry():
	if Input.is_action_just_pressed("parry"):
		dispatch(&"parry")

func input_for_shield_block() -> bool:
	if Input.is_action_pressed("shield_block"):
		shield_hold_time += get_process_delta_time()
		if shield_hold_time >= SHIELD_HOLD_THRESHOLD:
			if get_active_state() != shield_block:
				dispatch(&"shield_block")
			return true
		return false
	else:
		shield_hold_time = 0.0
		if get_active_state() == shield_block:
			return false
	return false
#endregion Inputs 
