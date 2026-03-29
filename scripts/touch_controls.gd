extends CanvasLayer

# Touch control overlay for mobile / web usage.
# Each on-screen button simulates the corresponding input action so that
# the existing player.gd keyboard logic works without modification.

@onready var left_button: Button = $Controls/LeftButton
@onready var right_button: Button = $Controls/RightButton
@onready var jump_button: Button = $Controls/JumpButton
@onready var down_button: Button = $Controls/DownButton
@onready var collect_button: Button = $Controls/CollectButton

func _ready() -> void:
	left_button.button_down.connect(_press.bind("move_left"))
	left_button.button_up.connect(_release.bind("move_left"))

	right_button.button_down.connect(_press.bind("move_right"))
	right_button.button_up.connect(_release.bind("move_right"))

	jump_button.button_down.connect(_press.bind("move_up"))
	jump_button.button_up.connect(_release.bind("move_up"))

	down_button.button_down.connect(_press.bind("move_down"))
	down_button.button_up.connect(_release.bind("move_down"))

	collect_button.button_down.connect(_press.bind("collect"))
	collect_button.button_up.connect(_release.bind("collect"))

func _press(action: String) -> void:
	Input.action_press(action)

func _release(action: String) -> void:
	Input.action_release(action)
