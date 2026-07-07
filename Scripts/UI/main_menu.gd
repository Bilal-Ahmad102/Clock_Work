extends Control

## Main menu: Play / Options / Quit. The Options panel is the shared
## options_menu scene; while it is open the button column hides.

@export_file("*.tscn") var play_scene := "res://Scenes/intro_level.tscn"

@onready var buttons: VBoxContainer = %Buttons
@onready var options: PanelContainer = %Options
@onready var play_button: Button = %PlayButton


func _ready() -> void:
	play_button.grab_focus()
	play_button.pressed.connect(_on_play)
	%OptionsButton.pressed.connect(_on_options)
	%QuitButton.pressed.connect(func() -> void: get_tree().quit())
	options.closed.connect(_on_options_closed)


func _on_play() -> void:
	LoadingScreen.target_scene = play_scene
	get_tree().change_scene_to_file("res://Scenes/UI/loading_screen.tscn")


func _on_options() -> void:
	buttons.visible = false
	options.visible = true
	options.focus_first()


func _on_options_closed() -> void:
	options.visible = false
	buttons.visible = true
	play_button.grab_focus()
