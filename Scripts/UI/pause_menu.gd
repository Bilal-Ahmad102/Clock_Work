extends CanvasLayer

## Global pause menu (autoload). "pause" (Esc / controller Start) toggles
## it in any level; ignored while the main menu scene is active. The
## CanvasLayer runs with PROCESS_MODE_ALWAYS so the menu keeps working
## while the tree is paused.

const MAIN_MENU_SCENE := "res://Scenes/UI/main_menu.tscn"

@onready var root: Control = %Root
@onready var buttons: VBoxContainer = %Buttons
@onready var options: PanelContainer = %Options
@onready var resume_button: Button = %ResumeButton


func _ready() -> void:
	root.visible = false
	resume_button.pressed.connect(_resume)
	%OptionsButton.pressed.connect(_show_options)
	%MenuButton.pressed.connect(_to_main_menu)
	%QuitButton.pressed.connect(func() -> void: get_tree().quit())
	options.closed.connect(_on_options_closed)


func _input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"pause"):
		return
	var scene := get_tree().current_scene
	if scene != null and scene.is_in_group("MainMenu"):
		return
	if root.visible:
		_resume()
	else:
		_pause()
	get_viewport().set_input_as_handled()


func _pause() -> void:
	get_tree().paused = true
	root.visible = true
	buttons.visible = true
	options.visible = false
	resume_button.grab_focus()


func _resume() -> void:
	get_tree().paused = false
	root.visible = false


func _show_options() -> void:
	buttons.visible = false
	options.visible = true
	options.focus_first()


func _on_options_closed() -> void:
	options.visible = false
	buttons.visible = true
	resume_button.grab_focus()


func _to_main_menu() -> void:
	get_tree().paused = false
	root.visible = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
