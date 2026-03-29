extends Area2D

signal collected(egg: Node2D)
signal stolen(egg: Node2D)
signal self_incubated(egg: Node2D)

enum State { ON_GROUND, BEING_SAT_ON, COLLECTED, STOLEN, SELF_INCUBATED }

@onready var chicken_sit_timer: Timer = $ChickenSitTimer
@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var egg_polygon: Polygon2D = $EggPolygon

var state: State = State.ON_GROUND
var sitting_chicken: Node2D = null

func _ready() -> void:
	chicken_sit_timer.timeout.connect(_on_chicken_sat_complete)
	lifetime_timer.timeout.connect(_on_lifetime_expired)
	lifetime_timer.start(30.0)
	add_to_group("eggs")

func collect() -> bool:
	if state != State.ON_GROUND and state != State.BEING_SAT_ON:
		return false
	state = State.COLLECTED
	if sitting_chicken and sitting_chicken.has_method("egg_taken"):
		sitting_chicken.egg_taken()
		sitting_chicken = null
	chicken_sit_timer.stop()
	lifetime_timer.stop()
	collected.emit(self)
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	return true

func start_being_sat_on(chicken: Node2D) -> void:
	if state != State.ON_GROUND:
		return
	state = State.BEING_SAT_ON
	sitting_chicken = chicken
	chicken_sit_timer.start(20.0)

func stop_being_sat_on() -> void:
	if state != State.BEING_SAT_ON:
		return
	state = State.ON_GROUND
	sitting_chicken = null
	chicken_sit_timer.stop()

func steal() -> void:
	if state == State.COLLECTED or state == State.STOLEN:
		return
	state = State.STOLEN
	stolen.emit(self)
	if sitting_chicken and sitting_chicken.has_method("egg_taken"):
		sitting_chicken.egg_taken()
	chicken_sit_timer.stop()
	lifetime_timer.stop()
	queue_free()

func _on_chicken_sat_complete() -> void:
	if state == State.BEING_SAT_ON:
		state = State.SELF_INCUBATED
		self_incubated.emit(self)
		if sitting_chicken and sitting_chicken.has_method("egg_hatched_naturally"):
			sitting_chicken.egg_hatched_naturally()
		queue_free()

func _on_lifetime_expired() -> void:
	if state == State.ON_GROUND or state == State.BEING_SAT_ON:
		queue_free()
