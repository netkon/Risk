extends "res://addons/gut/test.gd"

var funct = preload("res://Scripts/GameState.gd")
var funct1 = preload("res://Lobby.tscn")

func _ready():
	var funca = funct.new()
	var funca1 = funct1.instance()
	funca1.setPlayerName("ivo")
	funca1._on_ConnectButton_pressed()
	
func test_assert_eq_diceroll():
	pass
		
