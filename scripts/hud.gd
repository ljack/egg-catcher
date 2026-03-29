extends CanvasLayer

@onready var basket_label: Label = $MarginContainer/HBoxContainer/BasketLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel
@onready var character_label: Label = $MarginContainer/HBoxContainer/CharacterLabel

func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	var data = GameManager.get_character_data()
	character_label.text = data.name
	_on_score_changed(0)

func update_basket(count: int, capacity: int) -> void:
	basket_label.text = "Basket: " + str(count) + "/" + str(capacity)

func _on_score_changed(new_score: int) -> void:
	score_label.text = "Score: " + str(new_score)
