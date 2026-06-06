extends Label

@onready var state_machine: LimboHSM = %state_machine

const MAX_LINES: int = 8

var _log: Array[String] = []

func _process(_delta: float) -> void:
	var state_line := str(state_machine.get_active_state().name)
	text = state_line + "\n" + "\n".join(_log)

func add_debug(entry: String) -> void:
	_log.push_front(str(entry))
	if _log.size() > MAX_LINES:
		_log.resize(MAX_LINES)
