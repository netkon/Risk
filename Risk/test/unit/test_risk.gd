extends "res://addons/gut/test.gd"

var funct = preload("res://Scripts/Risk.gd")
var funca

func _ready():
	funca = funct.new()
	
func test_assert_eq_diceroll():
	assert_between(funca.diceRollNumber() , 1 , 6)
	
func test_assert_eq_turnoigualajogadores():
	assert_eq(funca.rolls.size() , GameState.playersingame.size())
		
