extends CanvasLayer

@onready var heavy_atk: TextureRect = %heavy_atk
@onready var magic_heavy_atk: TextureRect = %magic_heavy_atk
@onready var magic_dash_atk: TextureRect = %magic_dash_atk
@onready var light_atk: TextureRect = %light_atk
@onready var jump: TextureRect = %jump
@onready var state_machine: LimboHSM = %state_machine
@onready var dash: TextureRect = %dash


var state_to_icons: Dictionary
var state_to_magic_icons: Dictionary
var magic_mode: bool = false
var swap_pairs: Array = []

func _ready() -> void:

	state_to_icons = {
		state_machine.idle:        [light_atk, heavy_atk,dash],
		state_machine.walk:        [light_atk, heavy_atk,dash],
		state_machine.run:         [jump,dash,light_atk],
		state_machine.jump:        [dash],
		state_machine.fall:        [dash],
		state_machine.land:        [],
		state_machine.dash:        [],
		state_machine.combo_atk:   [],
		state_machine.heavy_atk:   [],
		state_machine.sprint_atk:  [],
		state_machine.shield_block:[],
		state_machine.parry:       [],
	}
	state_to_magic_icons = {
		state_machine.idle:        [light_atk,magic_dash_atk, magic_heavy_atk],
		state_machine.walk:        [light_atk,dash,heavy_atk],
		state_machine.run:         [jump,dash,light_atk],
		state_machine.jump:        [dash],
		state_machine.fall:        [dash],
		state_machine.land:        [],
		state_machine.dash:        [],
		state_machine.combo_atk:   [],
		state_machine.heavy_atk:   [],
		state_machine.sprint_atk:  [],
		state_machine.shield_block:[],
		state_machine.parry:       [],
	}
	swap_pairs = [
		[dash, magic_dash_atk],
		[heavy_atk, magic_heavy_atk],
		[light_atk, null],
	]
	for icon in [light_atk, heavy_atk, magic_heavy_atk, magic_dash_atk, jump, dash]:
		icon.pivot_offset = icon.size / 2.0
	state_machine.active_state_changed.connect(_on_state_changed)
	_refresh_icons(state_machine.get_active_state())

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("magic"):
		magic_mode = true
		_refresh_icons(state_machine.get_active_state())
	elif Input.is_action_just_released("magic"):
		magic_mode = false
		_refresh_icons(state_machine.get_active_state())
	debug_values()
func debug_values() -> void:
	var txt := "\nbrutality %.1f" % Audience.brutality
	txt += "\nrestraint %.1f" % Audience.restraint
	txt += "\nprecision %.1f" % Audience.precision
	txt += "\nhesitation %.1f" % Audience.hesitation
	txt += "\nrepetition %.1f" % Audience.repetition
	%values_label.text = txt
func _on_state_changed(_previous: LimboState, _next: LimboState) -> void:
	_refresh_icons(state_machine.get_active_state())


func _refresh_icons(active: LimboState) -> void:
	var all_icons := [light_atk, heavy_atk, magic_heavy_atk, magic_dash_atk, jump, dash]
	for icon in all_icons:
		icon.modulate.a = 0.3

	var current_map := state_to_magic_icons if magic_mode else state_to_icons
	if current_map.has(active):
		for icon in current_map[active]:
			if icon != null:
				icon.modulate.a = 1.0

	# swap pairs ; hide normal show magic or vice versa
	for pair in swap_pairs:
		var normal: TextureRect = pair[0]
		var magic: TextureRect  = pair[1]
		if magic == null:
			continue
		if magic_mode:
			normal.visible = false
			magic.visible  = true
		else:
			normal.visible = true
			magic.visible  = false

func _juice_icon(icon: TextureRect) -> void:
	var tween := create_tween()
	tween.tween_property(icon, "scale", Vector2(1.3, 1.3), 0.08).set_ease(Tween.EASE_OUT)
	tween.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.12).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(icon, "modulate", Color(1.5, 1.5, 0.6), 0.08)
	tween.tween_property(icon, "modulate", Color.WHITE, 0.12)
