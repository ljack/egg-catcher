extends Control

@onready var farmer_button: Button = $VBoxContainer/CharacterCards/FarmerCard/FarmerInfo/SelectButton
@onready var paul_button: Button = $VBoxContainer/CharacterCards/PaulCard/PaulInfo/SelectButton
@onready var farmer_card: PanelContainer = $VBoxContainer/CharacterCards/FarmerCard
@onready var paul_card: PanelContainer = $VBoxContainer/CharacterCards/PaulCard
@onready var fullscreen_button: Button = $VBoxContainer/FullscreenButton

var selected: String = "farmer"

func _ready() -> void:
	farmer_button.pressed.connect(_on_farmer_selected)
	paul_button.pressed.connect(_on_paul_selected)
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	# Only show fullscreen button on web platform
	fullscreen_button.visible = OS.has_feature("web")
	_highlight_selection()

func _on_farmer_selected() -> void:
	selected = "farmer"
	_highlight_selection()
	_start_game()

func _on_paul_selected() -> void:
	selected = "paul"
	_highlight_selection()
	_start_game()

func _highlight_selection() -> void:
	farmer_card.modulate = Color.WHITE if selected == "farmer" else Color(0.7, 0.7, 0.7)
	paul_card.modulate = Color.WHITE if selected == "paul" else Color(0.7, 0.7, 0.7)

func _on_fullscreen_pressed() -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("document.documentElement.requestFullscreen();")
		fullscreen_button.text = "Fullscreen Active"
		fullscreen_button.disabled = true

func _start_game() -> void:
	GameManager.selected_character = selected
	get_tree().change_scene_to_file("res://scenes/game.tscn")
