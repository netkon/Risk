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
var pressed = null
var fasedistribuicao = true
var mycolor

func _process(delta):
	pass
		
	
func _input(event):
	
	if $WorldMap/Dice.is_pressed():
		print("working")
		$WorldMap/Dice.disabled = true
		var diceroll = diceRollNumber()
		if get_tree().get_network_unique_id() == int(GameState.currentroominfo["gamehost"]): 
			$WorldMap/Dice.visible = false
			changeInfo("Waiting")
			diceRoll(diceroll , GameState.playername , get_tree().get_network_unique_id())
		else:
			$WorldMap/Dice.visible = false
			changeInfo("Waiting")
			rpc_id(GameState.currentroominfo["gamehost"] , "diceRoll" , diceroll , GameState.playername ,get_tree().get_network_unique_id())
	
	if turnready == true:
		if fasedistribuicao == true:
				if whosturn == get_tree().get_network_unique_id():
					for x in range(countries.size()):
						if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
							if countries[x] == pressed:
								get_node("WorldMap/FadeIn/" + countries[x]).modulate = mycolor
							else:
								if pressed != null:
									get_node("WorldMap/FadeIn/" + pressed).modulate = mycolor
								get_node("WorldMap/FadeIn/" + countries[x]).modulate = mycolor.darkened(0.3)
								print(str(countries[x]) + " is toggled" )
								pressed = countries[x]
								print(pressed)
							
							
					if $WorldMap/EndTurn.is_pressed():
						if pressed != null:
							var temp1 = int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text)
							get_node("WorldMap/FadeIn/" + pressed).modulate = mycolor
							print(temp1)
							temp1 += 1
							get_node("WorldMap/FadeIn/" + pressed + "/armycount").text = str(temp1)
							for x in GameState.playersingame:
								if x != get_tree().get_network_unique_id():
									rpc_id(x , "updateTroops" , pressed , temp1)
																	
							$WorldMap/EndTurn.visible = false
							for x in GameState.playersingame:
								if x != get_tree().get_network_unique_id():
									rpc_id(x , "turnChange")
							turnChange()
							changeInfo("Oponnent's Turn")
							pressed = null
							if infantry == 0:
								fasedistribuicao = false
			
		else:
			if whosturn == get_tree().get_network_unique_id():
				pass			
				
				
				
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
		if x == get_tree().get_network_unique_id():
			mycolor = colors[playerposition]
		setCountryColor(x , playerposition)
		playerposition += 1
	playerposition = 0
	print(mycolor)
	
	print(infantry)
	$WorldMap/FadingIn.play("anim")
	$WorldMap/Risk/LabelFade.play("Anim2")
	yield(get_tree().create_timer(6), "timeout")
	$WorldMap/Dice.visible = true
	$WorldMap/Dice/Dice/PopIn.play("PopIn")
	$WorldMap/Dice/Dice/Dice.play("Anim")
	changeInfo("Roll the Dice")
	$Info/fade.play("fade")


func screenResized():
	get_tree().get_root().set_size(OS.get_screen_size())
	get_tree().get_root().set_size_override_stretch(false)
	

func setCountryColor(id , position):
	for x in range(int(countries.size()/GameState.playersingame.size())):
		var playerid = Label.new()
		playerid.name = str(id)
		if id == get_tree().get_network_unique_id():
			infantry = infantry -1
		get_node("WorldMap/FadeIn/" + str(countries[count])).modulate = colors[position]
		get_node("WorldMap/FadeIn/" + str(countries[count])).add_child(playerid)
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

remote func turnChange():
	whosturn = rolls[0]["id"]
	print( "whos turn "  + str(whosturn))
	$Turn.text = str(rolls[0]["playername"]) + "'s Turn" 
	rolls.append(rolls[0])
	rolls.remove(0)
	print("after rolls " + str(rolls))
	$Turn._set_position(Vector2( 1366/2 - ($Turn.get_size().x)/2 , $Turn.get_position().y))
	$Turn/Fade1.play("fade")
	if whosturn == get_tree().get_network_unique_id():
		$WorldMap/EndTurn.visible = true
		changeInfo("Your Turn")
	else:
		changeInfo("Oponnent's Turn")
		
func changeInfo(word):
	$Info/fade.play_backwards("fade2")
	$Info.text = word
	$Info._set_position(Vector2(($WorldMap.texture.get_size().x)/2 - ($Info.get_size().x)/2 ,  $Info.get_position().y))
	$Info/fade.play("fade2")
	
remote func updateTroops(country , number):
	get_node("WorldMap/FadeIn/" + country + "/armycount").text = str(number)
