extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text
var roll = {"id" : "" , "roll" : "" , "playername" : ""}
var rolls = []
var colors = []
var countries = []
var playerposition = 0
var count = 0
var infantry
var turnready = false
var whosturn
var i = 0
var hovered = false

func _process(delta):
	pass
		
	
func _input(event):
	
	
	if turnready == true:
		if whosturn == get_tree().get_network_unique_id():
			print("myturn")
			for x in range(countries.size()):
				if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
					pass
			
			if $WorldMap/EndTurn.is_pressed():
				$WorldMap/EndTurn.visible = false
				for x in GameState.playersingame:
					if x != get_tree().get_network_unique_id():
						rpc_id(x , "turnChange")
				turnChange()
				
		
		
func _ready():
	
	get_tree().connect("screen_resized" , self , "screenResized")
	get_tree().get_root().set_size_override_stretch(false)
	get_tree().get_root().set_size(Vector2(1366,768))
	
	colors.append(Color( 0.7, 0, 0, 1 ))  #darkred
	colors.append(Color( 0, 0.7, 0, 1 )) #darkgreen
	colors.append(Color( 0.5, 0.5, 0, 1 ))
	colors.append(Color( 0.4, 0.2, 0.6, 1)) #purple
	colors.append(Color( 0, 0, 0.55, 1 )) #darkblue
	colors.append(Color( 1, 0.55, 0, 1 )) #darkorange
		
	if GameState.playersingame.size() == 6:
		infantry = 20
	elif GameState.playersingame.size() == 5:
		infantry = 25		
	elif GameState.playersingame.size() == 4:
		infantry = 30
	elif GameState.playersingame.size() == 3:
		infantry = 35
	elif GameState.playersingame.size() == 2:
		infantry = 40
	
	print(infantry)
	if get_tree().get_network_unique_id() == int(GameState.currentroominfo["gamehost"]):
		for x in $WorldMap/FadeIn.get_children():
			countries.append(x.name)
		countries.shuffle()
		
		for x in GameState.playersingame:
			if x != get_tree().get_network_unique_id():
				rpc_id(x , "updateCountries" , countries)
	
		gameStart()
	
func gameStart():
	print(countries)
	for x in GameState.playersingame:
		setCountryColor(x , playerposition)
		playerposition += 1
	playerposition = 0	
	
	print(infantry)
	$WorldMap/FadingIn.play("anim")
	$WorldMap/Risk/LabelFade.play("Anim2")
	yield(get_tree().create_timer(6), "timeout")
	$WorldMap/Dice.visible = true
	$WorldMap/Dice/Dice/PopIn.play("PopIn")
	$WorldMap/Dice/Dice/Dice.play("Anim")
	$Info.text = "Roll the dice"
	$Info/fade.play("fade")


func screenResized():
	get_tree().get_root().set_size(Vector2(1366,768))
	get_tree().get_root().set_size_override_stretch(false)
	


	
remote func updateCountries(newcountries):
	countries = newcountries
	gameStart()	

remote func diceRoll(diceroll , playername , id):
	roll["roll"] = diceroll
	roll["id"] = id
	roll["playername"] = str(playername)
	rolls.append(roll.duplicate())

	
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "updateScreenDice" , diceroll , playername , rolls.size())
	updateScreenDice(diceroll , playername, rolls.size())
			
	if rolls.size() == GameState.playersingame.size():
		for i in range(rolls.size()):
			for j in range(rolls.size() - i - 1):
				if rolls[j]["roll"]  > rolls[j+1]["roll"]:
					var temp = rolls[j+1]
					rolls[j+1] = rolls[j]
					rolls[j] = temp
		
		print("not inverted" + str(rolls))
		rolls.invert()
		print("inverted" + str(rolls))
		for x in GameState.playersingame:
			if x != get_tree().get_network_unique_id():
				rpc_id(x , "updateTurnInfo" , rolls)
		updateTurnInfo(rolls)	
		
remote func updateScreenDice(dicenumber , playername , size):
	var texture = load("res://Textures/Dice/" + str(dicenumber) + ".jpg")
	var sprite = Sprite.new()
	get_node("WorldMap").add_child(sprite)
	sprite.set_texture(texture)
	sprite.set_position(Vector2((get_tree().get_root().get_size().x)/2 + (size - GameState.playersingame.size() -i)*55, (get_tree().get_root().get_size().y)/2))
	i -= 1
	
func diceRollNumber():
	var roll = randi() % 6 + 1 
	return roll
	
static func sort(a, b):
	if a[0] < b[0]:
		return true
	return false

remote func updateTurnInfo(turns):
	rolls = turns
	print("inverted after " + str(rolls))
	yield(get_tree().create_timer(4), "timeout")
	for x in range(GameState.playersingame.size()):
		print(x)
		get_node("WorldMap/@@1" + str(x+2)).queue_free()
	turnready = true
	turnChange()