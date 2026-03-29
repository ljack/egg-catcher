extends Node

signal score_changed(new_score: int)
signal character_selected(character_id: String)

enum CharacterID { FARMER, PAUL }

var characters := {
	"farmer": {
		"name": "Farmer",
		"speed": 200.0,
		"jump_velocity": -600.0,
		"basket_capacity": 6,
		"color_body": Color(0.2, 0.4, 0.8),
		"color_head": Color(0.9, 0.75, 0.6),
		"color_hat": Color(0.6, 0.4, 0.2),
	},
	"paul": {
		"name": "Paul the Alien",
		"speed": 280.0,
		"jump_velocity": -520.0,
		"basket_capacity": 4,
		"color_body": Color(0.3, 0.8, 0.3),
		"color_head": Color(0.4, 0.9, 0.4),
		"color_hat": Color(0.2, 0.6, 0.2),
	}
}

var selected_character: String = "farmer"
var score: int = 0

func get_character_data() -> Dictionary:
	return characters[selected_character]

func add_score(points: int) -> void:
	score += points
	score_changed.emit(score)

func reset() -> void:
	score = 0
	score_changed.emit(score)
