extends "res://addons/gut/test.gd"

var funct = preload("res://Scripts/Risk.gd")

func test16():
	var dado = diceRollNumber.new()
	assert_between(roll , 1 , 6)
