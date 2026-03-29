extends CharacterBody2D

@onready var steal_area: Area2D = $StealArea
@onready var body_polygon: Polygon2D = $Body

var gravity: float = 980.0
var walk_speed: float = 35.0
var direction: float = 1.0
var platform_left: float = 0.0
var platform_right: float = 1152.0

func _ready() -> void:
	direction = [-1.0, 1.0].pick_random()
	add_to_group("beasts")

func setup_bounds(left: float, right: float) -> void:
	platform_left = left
	platform_right = right

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity.x = direction * walk_speed
	
	# Reverse at edges
	if global_position.x <= platform_left:
		direction = 1.0
	elif global_position.x >= platform_right:
		direction = -1.0
	
	body_polygon.scale.x = 1 if direction > 0 else -1
	
	move_and_slide()
	
	# Check for eggs to steal
	var areas = steal_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("eggs") and area.has_method("steal"):
			area.steal()
			break
