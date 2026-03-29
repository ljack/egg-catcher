extends CharacterBody2D

@onready var body_polygon: Polygon2D = $Body

var gravity: float = 980.0
var walk_speed: float = 30.0
var direction: float = 1.0
var walk_timer: float = 0.0
var walk_duration: float = 2.0
var idle_timer: float = 0.0
var is_idle: bool = false

func _ready() -> void:
	direction = [-1.0, 1.0].pick_random()
	walk_duration = randf_range(1.0, 3.0)
	add_to_group("chicks")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if is_idle:
		velocity.x = 0
		idle_timer += delta
		if idle_timer >= 1.5:
			is_idle = false
			direction = [-1.0, 1.0].pick_random()
			walk_duration = randf_range(1.0, 3.0)
			walk_timer = 0.0
	else:
		velocity.x = direction * walk_speed
		walk_timer += delta
		if walk_timer >= walk_duration:
			is_idle = true
			idle_timer = 0.0
	
	# Stay on screen
	if global_position.x < 20:
		direction = 1.0
	elif global_position.x > 1132:
		direction = -1.0
	
	body_polygon.scale.x = 1 if direction > 0 else -1
	
	move_and_slide()
