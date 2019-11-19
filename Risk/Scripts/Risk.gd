extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text
var roll = {"id" : "" , "roll" : "" , "playername" : "" , "color" : ""}
var rolls = []
var colors = []
var countries = []
var playerposition = 0
var count = 0
var infantry
var territories = 0
var turnready = false
var whosturn
var i = 0
var hovered = false
var pressed = null
var fasedistribuicao = true
var mycolor
var placeturn
var attackturn
var fortifyturn

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
			diceRoll(diceroll , GameState.playername , get_tree().get_network_unique_id() , mycolor)
		else:
			$WorldMap/Dice.visible = false
			changeInfo("Waiting")
			rpc_id(GameState.currentroominfo["gamehost"] , "diceRoll" , diceroll , GameState.playername ,get_tree().get_network_unique_id() , mycolor)
	
	if turnready == true:
		if fasedistribuicao == true:
				if whosturn == get_tree().get_network_unique_id():
					for x in range(countries.size()):
						if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
							changePressed(countries[x])

					if $WorldMap/EndTurn.is_pressed():
						if pressed != null:
							infantry = infantry -1
							var ntroops = int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text)
							ntroops += 1
							get_node("WorldMap/FadeIn/" + pressed + "/armycount").text = str(ntroops)
							
							get_node("WorldMap/FadeIn/" + pressed).modulate = mycolor
							
							for x in GameState.playersingame:
								if x != get_tree().get_network_unique_id():
									rpc_id(x , "updateTroops" , pressed , ntroops)
																	
							$WorldMap/EndTurn.visible = false
							for x in GameState.playersingame:
								if x != get_tree().get_network_unique_id():
									rpc_id(x , "turnChange")
							turnChange()
							
							pressed = null
							print("infantry number = " + str(infantry))
							
							if infantry == 0:
								$Turn/Panel.visible = true
								fasedistribuicao = false
			
		else:
			if whosturn == get_tree().get_network_unique_id():
				
				if placeturn == true:
					for x in range(countries.size()):
						if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
							if countries[x] == pressed:
								$AddTroops/appear.play_backwards("appear")
							else:
								var node = get_node("WorldMap/FadeIn/" + str(countries[x]))
								$AddTroops.set_position(Vector2(node.get_position().x + (node.get_size().x)/2 , node.get_position().y))
								$AddTroops/appear.play("appear")
								
							changePressed(countries[x])

					
					if $AddTroops/Plus.is_pressed() and int($AddTroops/HMTroops.text) < infantry:
						$AddTroops/HMTroops.text = str(int($AddTroops/HMTroops.text) + 1)
					
					if $AddTroops/Minus.is_pressed() and int($AddTroops/HMTroops.text) > 0:
						$AddTroops/HMTroops.text = str(int($AddTroops/HMTroops.text) - 1)
					
					if int($AddTroops/HMTroops.text) > infantry:
						$AddTroops/HMTroops.text = str(infantry)
						
					if $AddTroops.is_visible() and Input.is_key_pressed(KEY_ENTER) and int($AddTroops/HMTroops.text) <= infantry:
						get_node("WorldMap/FadeIn/" + pressed + "/armycount").text = str(int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) + int($AddTroops/HMTroops.text))
						infantry = infantry - int($AddTroops/HMTroops.text)
						for x in GameState.playersingame:
								if x != get_tree().get_network_unique_id():
									rpc_id(x , "updateTroops" , pressed , int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text))
						
						$AddTroops/HMTroops.text = str(0)
						$AddTroops/appear.play_backwards("appear")
						
				elif attackturn == true:
					for x in range(countries.size()):
						if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
							changePressed(countries[x])		
				elif fortifyturn == true:
					for x in range(countries.size()):
						if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
							changePressed(countries[x])
			
				if 	$WorldMap/EndTurn.is_pressed() and placeturn == true:
					placeturn = false
					attackturn = true
					if pressed != null:
						get_node("WorldMap/FadeIn/" + pressed).modulate = mycolor
						pressed = null
						$AddTroops/appear.play_backwards("appear")
					changeLabelTurn("Attack")

					
				elif $WorldMap/EndTurn.is_pressed() and attackturn == true:
					attackturn = false
					fortifyturn = true
					if pressed != null:
						pressed = null
					changeLabelTurn("Fortify")
				
				elif $WorldMap/EndTurn.is_pressed() and fortifyturn == true:
					fortifyturn = false
					$WorldMap/EndTurn.visible = false
					if pressed != null:
						get_node("WorldMap/FadeIn/" + pressed).modulate = mycolor
						pressed = null
					for x in GameState.playersingame:
						if x != get_tree().get_network_unique_id():
							rpc_id(x , "turnChange")
					turnChange()
				
	if $Lip.is_hovered() and hovered == false:
		$Lip/Stats/hopping.play("hopping")
		hovered = true
		
	if $Lip/Stats.is_pressed() and hovered == true:
		$Lip/Stats/hopping.play_backwards("hopping")
		hovered = false
		
		
func _ready():
	$Dark/DarkFadein.play("fade")
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
		infantry = 22
	
	$Dark.visible = false
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
	print(territories)

	$WorldMap/FadingIn.play("anim")
	$WorldMap/Risk/LabelFade.play("Anim2")
	yield(get_tree().create_timer(6), "timeout")
	$WorldMap/Dice.visible = true
	$WorldMap/Dice/Dice/PopIn.play("PopIn")
	$WorldMap/Dice/Dice/Dice.play("Anim")
	changeInfo("Roll the Dice")


func screenResized():
	get_tree().get_root().set_size(OS.get_screen_size())
	get_tree().get_root().set_size_override_stretch(false)
	

func setCountryColor(id , position):
	for x in range(int(countries.size()/GameState.playersingame.size())):
		var playerid = Label.new()
		playerid.name = str(id)
		if id == get_tree().get_network_unique_id():
			infantry = infantry -1
			territories = territories +1
		get_node("WorldMap/FadeIn/" + str(countries[count])).modulate = colors[position]
		get_node("WorldMap/FadeIn/" + str(countries[count])).add_child(playerid)
		count += 1	
	
remote func updateCountries(newcountries):
	countries = newcountries
	gameStart()	

remote func diceRoll(diceroll , playername , id , color):
	roll["roll"] = diceroll
	roll["id"] = id
	roll["playername"] = str(playername)
	roll["color"] = color
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
	get_node("WorldMap/TempDice/").add_child(sprite)
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
	for x in $WorldMap/TempDice.get_children():
		x.queue_free()
	turnready = true
	turnChange()

remote func turnChange():
	whosturn = rolls[0]["id"]
	print( "whos turn "  + str(whosturn))
	
	if whosturn != get_tree().get_network_unique_id():
		$Turn.text = str(rolls[0]["playername"]) + "'s Turn"
	else:
		$Turn.text = "Your Turn"
	$Turn.self_modulate = rolls[0]["color"]
	$Turn/Fade1.play("fade")
	
	rolls.append(rolls[0])
	rolls.remove(0)
	
	$Info/fade.play_backwards("fade")
	yield(get_tree().create_timer(3), "timeout")
	
	if whosturn == get_tree().get_network_unique_id():
		$WorldMap/EndTurn.visible = true
		changeInfo("Your Turn")
		if fasedistribuicao == false:
			if territories <= 9:
				infantry = infantry +3
			else:
				infantry = infantry + int(territories/3)
				
			print(infantry)
			placeturn = true
			changeLabelTurn("Place")
	else:
		changeInfo("Oponnent's Turn")
		pass
		
func changeInfo(word):
	$Info.text = word
	$Info/fade.play("fade")

	
remote func updateTroops(country , number):
	get_node("WorldMap/FadeIn/" + country + "/armycount").text = str(number)

func testChange():
	rolls.append(rolls[0])
	rolls.remove(0)

func changeLabelTurn(text):
	$WorldMap/EndTurn/Label.text = text

func changePressed(country):
	if country == pressed:
		get_node("WorldMap/FadeIn/" + country).modulate = mycolor
		pressed = null
	else:
		if pressed != null:
			get_node("WorldMap/FadeIn/" + pressed).modulate = mycolor
		get_node("WorldMap/FadeIn/" + country).modulate = mycolor.darkened(0.3)
		print(str(country) + " is toggled" )
		pressed = country
		print(pressed)
