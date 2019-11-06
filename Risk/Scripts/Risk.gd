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
	
	if $WorldMap/Dice.is_pressed():
		print("working")
		$WorldMap/Dice.disabled = true
		var diceroll = diceRollNumber()
		if get_tree().get_network_unique_id() == int(GameState.currentroominfo["gamehost"]): 
			$WorldMap/Dice.visible = false
			$Info/fade.play_backwards("fade2")
			$Info._set_position(Vector2($Info.get_position().x + 100 ,  $Info.get_position().y))
			$Info.text = "Waiting"
			$Info/fade.play("fade2")
			diceRoll(diceroll , GameState.playername , get_tree().get_network_unique_id())
		else:
			$WorldMap/Dice.visible = false
			$Info/fade.play_backwards("fade2")
			$Info._set_position(Vector2($Info.get_position().x + 100 ,  $Info.get_position().y))
			$Info.text = "Waiting"
			$Info/fade.play("fade2")
			rpc_id(GameState.currentroominfo["gamehost"] , "diceRoll" , diceroll , GameState.playername ,get_tree().get_network_unique_id())
	

				
	if $Lip.is_hovered() and hovered == false:
		$Lip/Stats/hopping.play("hopping")
		hovered = true
		
	if $Lip/Stats.is_pressed() and hovered == true:
		$Lip/Stats/hopping.play_backwards("hopping")
		hovered = false
		
		
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
	

func setCountryColor(id , position):
	for x in range(int(countries.size()/GameState.playersingame.size())):
		var playerid = Label.new()
		var infantryn = Label.new()
		playerid.name = str(id)
		infantryn.name = "armycount"
		infantryn.text = str(1)
		infantryn.visible = false
		if id == get_tree().get_network_unique_id():
			infantry = infantry -1
		get_node("WorldMap/FadeIn/" + str(countries[count])).modulate = colors[position]
		get_node("WorldMap/FadeIn/" + str(countries[count])).add_child(playerid)
		get_node("WorldMap/FadeIn/" + str(countries[count])).add_child(infantryn)
		count += 1	
	
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
		

	
func diceRollNumber():
	var roll = randi() % 6 + 1 
	return roll
	
static func sort(a, b):
	if a[0] < b[0]:
		return true
	return false

remote func turnChange():
	whosturn = rolls[0]["id"]
	print( "whos turn "  + str(whosturn))
	$Turn.text = str(rolls[0]["playername"]) + "'s Turn" 
	rolls.append(rolls[0]["id"])
	rolls.remove(0)
	$Turn._set_position(Vector2( 1366/2 - ($Turn.get_size().x)/2 , $Turn.get_position().y))
	$Turn/Fade1.play("fade")
	if whosturn == get_tree().get_network_unique_id():
		$WorldMap/EndTurn.visible = true
