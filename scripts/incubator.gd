extends StaticBody2D

signal chick_hatched(position: Vector2)

@onready var deposit_zone: Area2D = $DepositZone
@onready var hatch_timer: Timer = $HatchTimer
@onready var egg_count_label: Label = $EggCountLabel
@onready var body_polygon: Polygon2D = $Body
@onready var glow_polygon: Polygon2D = $Glow

var eggs_inside: int = 0
var hatch_progress: float = 0.0
const HATCH_TIME: float = 12.0
const CHICK_SCENE = preload("res://scenes/chick.tscn")

func _ready() -> void:
	deposit_zone.add_to_group("incubator_zone")
	hatch_timer.wait_time = 1.0
	hatch_timer.timeout.connect(_on_hatch_tick)
	_update_label()

func receive_eggs(eggs: Array) -> int:
	var count = eggs.size()
	eggs_inside += count
	for egg in eggs:
		if is_instance_valid(egg):
			egg.queue_free()
	_update_label()
	if eggs_inside > 0 and hatch_timer.is_stopped():
		hatch_progress = 0.0
		hatch_timer.start()
	return count

func _on_hatch_tick() -> void:
	if eggs_inside <= 0:
		hatch_timer.stop()
		return
	
	hatch_progress += 1.0
	# Pulse glow
	var t = hatch_progress / HATCH_TIME
	glow_polygon.modulate.a = 0.3 + 0.4 * sin(t * TAU * 2)
	
	if hatch_progress >= HATCH_TIME:
		# Hatch one egg
		eggs_inside -= 1
		hatch_progress = 0.0
		_spawn_chick()
		GameManager.add_score(10)
		_update_label()
		
		if eggs_inside <= 0:
			hatch_timer.stop()
			glow_polygon.modulate.a = 0.0

func _spawn_chick() -> void:
	var chick = CHICK_SCENE.instantiate()
	chick.global_position = global_position + Vector2(randf_range(-30, 30), -20)
	get_tree().current_scene.add_child(chick)
	chick_hatched.emit(chick.global_position)

func _update_label() -> void:
	egg_count_label.text = str(eggs_inside) + " eggs"
