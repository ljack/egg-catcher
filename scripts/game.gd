extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var incubator: StaticBody2D = $Incubator

# Platform positions and bounds: [chicken_node, left_bound, right_bound]
# Chicken bounds match platform positions ±170px (platform is 400px wide)
var chicken_configs := [
	["Chicken1", -50.0, 290.0],    # Platform1 at x=120
	["Chicken2", 280.0, 620.0],    # Platform2 at x=450
	["Chicken3", -20.0, 320.0],    # Platform3 at x=150
	["Chicken4", 330.0, 670.0],    # Platform4 at x=500
	["Chicken5", 680.0, 1020.0],   # Platform5 at x=850
	["Chicken6", 780.0, 1120.0],   # Platform6 at x=950
	["Chicken7", 580.0, 920.0],    # Platform7 at x=750
]

var beast_configs := [
	["Beast1", 20.0, 1130.0],
	["Beast2", 20.0, 1130.0],
]

func _ready() -> void:
	GameManager.reset()
	player.basket_changed.connect(hud.update_basket)

	# Set up chicken platform bounds
	for config in chicken_configs:
		var chicken = get_node(config[0])
		if chicken:
			chicken.setup_bounds(config[1], config[2])

	# Set up beast bounds
	for config in beast_configs:
		var beast = get_node(config[0])
		if beast:
			beast.setup_bounds(config[1], config[2])

	# Ensure incubator deposit zone is in the right group
	var deposit_zone = incubator.get_node("DepositZone")
	if deposit_zone:
		deposit_zone.add_to_group("incubator_zone")

	# Loop background music
	$BGMusic.finished.connect($BGMusic.play)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
