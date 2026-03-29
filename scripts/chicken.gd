extends CharacterBody2D

signal egg_laid(position: Vector2)

enum ChickenState { IDLE, WALKING, GOING_TO_EGG, SITTING }

@onready var egg_lay_timer: Timer = $EggLayTimer
@onready var body_polygon: Polygon2D = $Body
@onready var head_polygon: Polygon2D = $Head

var state: ChickenState = ChickenState.IDLE
var gravity: float = 980.0
var walk_speed: float = 40.0
var direction: float = 1.0
var platform_left: float = 0.0
var platform_right: float = 200.0
var current_egg: Node2D = null
var idle_timer: float = 0.0
var idle_duration: float = 2.0

const EGG_SCENE = preload("res://scenes/egg.tscn")

func _ready() -> void:
	egg_lay_timer.wait_time = randf_range(5.0, 12.0)
	egg_lay_timer.timeout.connect(_on_lay_timer)
	egg_lay_timer.start()
	idle_duration = randf_range(1.0, 3.0)
	add_to_group("chickens")

func setup_bounds(left: float, right: float) -> void:
	platform_left = left
	platform_right = right

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	match state:
		ChickenState.IDLE:
			velocity.x = 0
			idle_timer += delta
			if idle_timer >= idle_duration:
				state = ChickenState.WALKING
				direction = [-1.0, 1.0].pick_random()
				idle_timer = 0.0
		
		ChickenState.WALKING:
			velocity.x = direction * walk_speed
			idle_timer += delta
			if idle_timer >= 2.0:
				state = ChickenState.IDLE
				idle_timer = 0.0
				idle_duration = randf_range(1.0, 3.0)
			# Reverse at platform edges
			if global_position.x <= platform_left:
				direction = 1.0
			elif global_position.x >= platform_right:
				direction = -1.0
			# Flip visuals
			body_polygon.scale.x = 1 if direction > 0 else -1
			head_polygon.scale.x = 1 if direction > 0 else -1
		
		ChickenState.GOING_TO_EGG:
			if current_egg == null or not is_instance_valid(current_egg):
				state = ChickenState.IDLE
				current_egg = null
				return
			var dir_to_egg = sign(current_egg.global_position.x - global_position.x)
			velocity.x = dir_to_egg * walk_speed
			body_polygon.scale.x = 1 if dir_to_egg > 0 else -1
			head_polygon.scale.x = 1 if dir_to_egg > 0 else -1
			if abs(global_position.x - current_egg.global_position.x) < 10:
				state = ChickenState.SITTING
				velocity.x = 0
				if current_egg.has_method("start_being_sat_on"):
					current_egg.start_being_sat_on(self)
		
		ChickenState.SITTING:
			velocity.x = 0
			if current_egg == null or not is_instance_valid(current_egg):
				state = ChickenState.IDLE
				current_egg = null
	
	move_and_slide()

func _on_lay_timer() -> void:
	if state == ChickenState.SITTING:
		egg_lay_timer.wait_time = randf_range(5.0, 12.0)
		egg_lay_timer.start()
		return
	
	# Spawn egg
	var egg = EGG_SCENE.instantiate()
	egg.global_position = global_position + Vector2(0, 5)
	get_tree().current_scene.add_child(egg)
	egg_laid.emit(global_position)
	
	# Wait before going to sit on the egg (gives player time to grab it)
	current_egg = egg
	await get_tree().create_timer(3.0).timeout
	if current_egg and is_instance_valid(current_egg):
		state = ChickenState.GOING_TO_EGG
	
	# Reset timer for next egg
	egg_lay_timer.wait_time = randf_range(5.0, 12.0)
	egg_lay_timer.start()

func egg_taken() -> void:
	current_egg = null
	state = ChickenState.IDLE

func egg_hatched_naturally() -> void:
	current_egg = null
	state = ChickenState.IDLE
