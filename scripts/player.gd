extends CharacterBody2D

signal basket_changed(count: int, capacity: int)

@onready var collect_area: Area2D = $CollectArea
@onready var deposit_area: Area2D = $DepositArea
@onready var body_polygon: Polygon2D = $Body
@onready var head_polygon: Polygon2D = $Head
@onready var hat_polygon: Polygon2D = $Hat
@onready var basket_label: Label = $BasketLabel

var speed: float = 200.0
var jump_velocity: float = -400.0
var basket_capacity: int = 6
var basket: Array = []
var near_incubator: Node2D = null
var gravity: float = 980.0
var facing_right: bool = true

func _ready() -> void:
	var data = GameManager.get_character_data()
	speed = data.speed
	jump_velocity = data.jump_velocity
	basket_capacity = data.basket_capacity
	body_polygon.color = data.color_body
	head_polygon.color = data.color_head
	hat_polygon.color = data.color_hat
	
	deposit_area.area_entered.connect(_on_deposit_area_entered)
	deposit_area.area_exited.connect(_on_deposit_area_exited)
	basket_changed.emit(basket.size(), basket_capacity)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Jump
	if Input.is_action_just_pressed("move_up") and is_on_floor():
		velocity.y = jump_velocity

	# Drop through one-way platforms
	if Input.is_action_pressed("move_down") and is_on_floor():
		position.y += 2
	
	# Horizontal movement
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		if direction > 0 and not facing_right:
			_flip(true)
		elif direction < 0 and facing_right:
			_flip(false)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	
	# Collect eggs
	if Input.is_action_just_pressed("collect"):
		_try_collect_eggs()
	
	# Auto-deposit at incubator
	if near_incubator and basket.size() > 0:
		_deposit_eggs()
	
	# Update basket label
	basket_label.text = str(basket.size()) + "/" + str(basket_capacity)

func _try_collect_eggs() -> void:
	if basket.size() >= basket_capacity:
		return
	var areas = collect_area.get_overlapping_areas()
	for area in areas:
		if basket.size() >= basket_capacity:
			break
		if area.has_method("collect"):
			if area.collect():
				basket.append(area)
				basket_changed.emit(basket.size(), basket_capacity)

func _deposit_eggs() -> void:
	if near_incubator and near_incubator.has_method("receive_eggs"):
		var deposited = near_incubator.receive_eggs(basket)
		basket.clear()
		basket_changed.emit(basket.size(), basket_capacity)

func _on_deposit_area_entered(area: Area2D) -> void:
	if area.is_in_group("incubator_zone"):
		near_incubator = area.get_parent()

func _on_deposit_area_exited(area: Area2D) -> void:
	if area.is_in_group("incubator_zone"):
		near_incubator = null

func _flip(right: bool) -> void:
	facing_right = right
	var s = 1 if right else -1
	body_polygon.scale.x = s
	head_polygon.scale.x = s
	hat_polygon.scale.x = s
