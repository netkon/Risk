extends "res://addons/gut/test.gd"

var funct = preload("res://Scripts/Risk.gd")

func _ready():
	var funca = funct.new()
	
func test_assert_eq_diceroll():
	var funca = funct.new()
	assert_between(funca.diceRollNumber() , 1 , 6)
	
func test_assert_eq_turnoigualajogadores():
	var funca = funct.new()
	funca.rolls = [{"id" : "1" , "roll" : "3" , "playername" : "ivo"} , {"id" : "3" , "roll" : "3" , "playername" : "manel"}]
	var temp = funca.rolls.size()
	funca.testChange()
	assert_eq(temp , funca.rolls.size())
		
