extends Node

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
var colortemp = []
var pressedattack
var pressedmove
var timetoattack = false
var rpcsenderid
var defenderdice = []
var attackerdice = []
var cards = []
var cardsinhand = []
var getcard = false
var cardspressed = false
var cardchecked = []
var infantrycards = 4
var movingdone = false

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
							addInfantry(-1)
							var ntroops = int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text)
							ntroops += 1
							get_node("WorldMap/FadeIn/" + pressed + "/armycount").text = str(ntroops)
							
							remoteModulate(pressed , mycolor)
							for x in GameState.playersingame:
								if x != get_tree().get_network_unique_id():
									rpc_id(x , "updateTroops" , pressed , ntroops)
																	
							$WorldMap/EndTurn.visible = false
							$WorldMap/EndTurn/Fade.play_backwards("fade")
							for x in GameState.playersingame:
								if x != get_tree().get_network_unique_id():
									rpc_id(x , "turnChange")
							turnChange()
							
							pressed = null
							print("infantry number = " + str(infantry))
							
							if infantry == 0:
								$Turn/Panel.visible = true
								$WorldMap/CardHolder/fade.play("fadei")
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
						$AddTroops/TroopsSlider.value = int($AddTroops/HMTroops.text)
					
					if $AddTroops/Minus.is_pressed() and int($AddTroops/HMTroops.text) > 0:
						$AddTroops/HMTroops.text = str(int($AddTroops/HMTroops.text) - 1)
						$AddTroops/TroopsSlider.value = int($AddTroops/HMTroops.text)
					
					if int($AddTroops/HMTroops.text) > infantry:
						$AddTroops/HMTroops.text = str(infantry)
						
					if $AddTroops.is_visible() and (Input.is_key_pressed(KEY_ENTER) or $AddTroops/OkButton.is_pressed()) and int($AddTroops/HMTroops.text) <= infantry:
						get_node("WorldMap/FadeIn/" + pressed + "/armycount").text = str(int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) + int($AddTroops/HMTroops.text))
						addInfantry(-int($AddTroops/HMTroops.text))
						for x in GameState.playersingame:
							if x != get_tree().get_network_unique_id():
								rpc_id(x , "updateTroops" , pressed , int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text))
						
						#$AddTroops/HMTroops.text = str(0)
						$AddTroops/appear.play_backwards("appear")
						remoteModulate(pressed , mycolor)
					
				elif attackturn == true:
					if pressed == null:
						for x in range(countries.size()):
							if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
								pressed = countries[x]
								remoteModulateDark(pressed , mycolor)
								remoteAttackPressedDark(pressed , get_tree().get_network_unique_id())
					else:
						for x in range(countries.size()):
							if timetoattack == false:
								if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
									if countries[x] == pressed:
										remoteModulate(pressed , mycolor)
										remoteAttackPressed(pressed , get_tree().get_network_unique_id())
										pressed = null
										if $WorldMap/AttackButton.is_visible() == true:
											$WorldMap/AttackButton/appear.play_backwards("appear")
									
									elif has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
										remoteModulate(pressed , mycolor)
										remoteModulateDark(countries[x] , mycolor)
										remoteAttackPressed(pressed , get_tree().get_network_unique_id())
										remoteAttackPressedDark(countries[x] , get_tree().get_network_unique_id())
										pressed = countries[x]
										if $WorldMap/AttackButton.is_visible() == true:
											$WorldMap/AttackButton/appear.play_backwards("appear")
								
								elif get_node("WorldMap/FadeIn/" + countries[x]).is_pressed()  and pressed != null:
									for z in get_node("WorldMap/FadeIn/" + pressed + "/neighbours").get_children():
										if z.name == countries[x]:
											pressedattack = countries[x]
											var node = get_node("WorldMap/FadeIn/" + str(countries[x]))
											$WorldMap/AttackButton.set_position(Vector2(node.get_position().x + (node.get_size().x)/2 , node.get_position().y))
											$WorldMap/AttackButton/appear.play("appear")
											
										
							if $WorldMap/AttackButton.is_pressed():
								
								if int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) < 2:
									pass
								else:
									timetoattack = true
									changeInfo("How many dice to throw")
									rpc_id(int(get_node("WorldMap/FadeIn/" + pressedattack).get_children()[2].name) , "throwDice" , pressed , pressedattack)
									
									$WorldMap/AttackButton/appear.play_backwards("appear")
									if int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) == 2:
										$AddDice/DiceSlider.max_value = 1
									elif int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) == 3:
										$AddDice/DiceSlider.max_value = 2
									else:
										$AddDice/DiceSlider.max_value = 3
									
									var node = get_node("WorldMap/FadeIn/" + str(pressedattack))
									$AddDice.set_position(Vector2(node.get_position().x + (node.get_size().x)/2 , node.get_position().y))
									$AddDice/appear.play("appear")
				
				elif fortifyturn == true and movingdone == false:
					if pressed == null:
						for x in range(countries.size()):
							if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())) and int(get_node(("WorldMap/FadeIn/" + countries[x] + "/armycount")).text) > 1:
								pressed = countries[x]
								remoteModulateDark(pressed , mycolor)
								remoteMovePressedDark(pressed , get_tree().get_network_unique_id())
					else:
						for x in range(countries.size()):
							if get_node("WorldMap/FadeIn/" + countries[x]).is_pressed() and has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())):
								if countries[x] == pressed and int(get_node(("WorldMap/FadeIn/" + countries[x] + "/armycount")).text) > 1:
									remoteModulate(pressed , mycolor)
									remoteMovePressed(pressed , get_tree().get_network_unique_id())
									pressed = null
									if $AddTroopsMove.is_visible() == true:
											$AddTroopsMove/appear.play_backwards("appear")
									
								elif has_node("WorldMap/FadeIn/" + countries[x] + "/" + str(get_tree().get_network_unique_id())) and pressed != null:
									var no = false
									for z in get_node("WorldMap/FadeIn/" + pressed + "/neighbours").get_children():
										if z.name == countries[x]:
											no = true
											pressedmove = countries[x]
											var node = get_node("WorldMap/FadeIn/" + str(countries[x]))
											$AddTroopsMove/MovekSliderM.min_value = 1
											$AddTroopsMove/MovekSliderM.max_value = int(get_node(("WorldMap/FadeIn/" + pressed + "/armycount")).text)-1
											$AddTroopsMove/MovekSliderM.value = 1
											$AddTroopsMove.set_position(Vector2(node.get_position().x + (node.get_size().x)/2 , node.get_position().y))
											$AddTroopsMove/appear.play("appear")

									if no == false and int(get_node(("WorldMap/FadeIn/" + countries[x] + "/armycount")).text) > 1:
										remoteModulate(pressed , mycolor)
										remoteMovePressed(pressed , get_tree().get_network_unique_id())
										remoteMovePressedDark(countries[x] , get_tree().get_network_unique_id())
										remoteModulateDark(countries[x] , mycolor)
										pressed = countries[x]
										if $AddTroopsMove.is_visible() == true:
											$AddTroopsMove/appear.play_backwards("appear")
										
				if 	$WorldMap/EndTurn.is_pressed() and placeturn == true:
					placeturn = false
					attackturn = true
					if pressed != null:
						remoteModulate(pressed , mycolor)
						pressed = null
						if $AddTroops.is_visible():
							$AddTroops/appear.play_backwards("appear")
					changeLabelTurn("Fortify")

					
				elif $WorldMap/EndTurn.is_pressed() and attackturn == true and timetoattack == false:
					attackturn = false
					fortifyturn = true
					if pressed != null:
						remoteModulate(pressed , mycolor)
						remoteAttackPressed(pressed , get_tree().get_network_unique_id())
						pressed = null
					changeLabelTurn("End Turn")
				
				elif $WorldMap/EndTurn.is_pressed() and fortifyturn == true:
					fortifyturn = false
					movingdone = false
					$WorldMap/EndTurn.visible = false
					$WorldMap/EndTurn/Fade.play_backwards("fade")
					if $AddTroopsMove.is_visible() == true:
						$AddTroopsMove/appear.play_backwards("appear")
											
					if getcard == true:
						getCard()	
						getcard = false
						
					if pressed != null:
						remoteModulate(pressed , mycolor)
						remoteMovePressed(pressed , get_tree().get_network_unique_id())
						pressed = null
					
					for x in GameState.playersingame:
						if x != get_tree().get_network_unique_id():
							rpc_id(x , "turnChange")
					turnChange()
				
				if placeturn == true or fortifyturn == true:
					for x in $WorldMap/CardHolder/CardsInHand.get_children():
						if x.is_pressed():
							if cardchecked.find(x) != -1:
								cardchecked.erase(x)
								x.set_position(Vector2(x.get_position().x , 700))
								if $WorldMap/CardHolder/TradeIn.is_visible() == true:
									$WorldMap/CardHolder/TradeIn.visible = false
								print(cardchecked)
							else:
								cardchecked.append(x)
								x.set_position(Vector2(x.get_position().x , 500))
								print(cardchecked)
								if cardchecked.size() == 3:
									checkCombinations()
							
				
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
			cards.append(x.name)
		countries.shuffle()
		cards.shuffle()

		for x in GameState.playersingame:
			if x != get_tree().get_network_unique_id():
				rpc_id(x , "updateCards" , cards)
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
	get_tree().get_root().set_size(Vector2(1366,768))
	get_tree().get_root().set_size_override_stretch(false)
	

func setCountryColor(id , position):
	for x in range(int(countries.size()/GameState.playersingame.size())):
		var playerid = Label.new()
		playerid.name = str(id)
		if id == get_tree().get_network_unique_id():
			addInfantry(-1)
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
	$WorldMap/holdDice.set_size(Vector2(GameState.playersingame.size()*150 , 200))
	$WorldMap/holdDice.set_position(Vector2(1366/2 - ($WorldMap/holdDice.get_size().x)/2, 768/2 - ($WorldMap/holdDice.get_size().y)/2 - 10) )
	$WorldMap/holdDice.visible = true
	var texture = load("res://Textures/Dice/" + str(dicenumber) + ".png")
	var sprite = Sprite.new()
	var label = get_node("WorldMap/TempDice/temp").duplicate()
	get_node("WorldMap/TempDice/").add_child(label)
	get_node("WorldMap/TempDice/").add_child(sprite)
	sprite.set_texture(texture)
	label.text = playername
	sprite.set_position(Vector2((get_tree().get_root().get_size().x)/2 + (size - GameState.playersingame.size() -i)*55, (get_tree().get_root().get_size().y)/2))
	label.set_position(Vector2(sprite.get_position().x, sprite.get_position().y - 80 ))
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
	$WorldMap/holdDice.visible = false
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
		$WorldMap/EndTurn/Fade.play("fade")
		changeInfo("Your Turn")
		if fasedistribuicao == false:
			if territories <= 9:
				addInfantry(3)
			else:
				addInfantry(int(territories/3))
				
			print(infantry)
			placeturn = true
			changeLabelTurn("Attack")
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
		remoteModulate(country , mycolor)
		pressed = null
	else:
		if pressed != null:
			remoteModulate(pressed , mycolor)
		remoteModulateDark(country , mycolor)
		pressed = country

remote func attackPressedDark(country , id):
	for x in get_node("WorldMap/FadeIn/" + country + "/neighbours").get_children():
		if !(has_node("WorldMap/FadeIn/" + x.name + "/" + str(id))):
			colortemp.append(get_node("WorldMap/FadeIn/" + x.name).get_modulate())
			get_node("WorldMap/FadeIn/" + x.name).modulate = colortemp.back().darkened(0.3)

remote func attackPressedLight(pressed , id):

	for x in get_node("WorldMap/FadeIn/" + pressed + "/neighbours").get_children():
		if !(has_node("WorldMap/FadeIn/" + x.name + "/" + str(id))):
			get_node("WorldMap/FadeIn/" + x.name).modulate = colortemp.pop_front()

func remoteAttackPressed(countrypressed , id):
	attackPressedLight(countrypressed , id)
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "attackPressedLight" , countrypressed , id)
	
func remoteAttackPressedDark(country , id ):
	attackPressedDark(country , id)
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "attackPressedDark" , country , id)
	
remote func movePressedDark(country , id):
	for x in get_node("WorldMap/FadeIn/" + country + "/neighbours").get_children():
		if (has_node("WorldMap/FadeIn/" + x.name + "/" + str(id))):
			colortemp.append(get_node("WorldMap/FadeIn/" + x.name).get_modulate())
			get_node("WorldMap/FadeIn/" + x.name).modulate = colortemp.back().darkened(0.3)

remote func movePressedLight(pressed , id):
	for x in get_node("WorldMap/FadeIn/" + pressed + "/neighbours").get_children():
		if (has_node("WorldMap/FadeIn/" + x.name + "/" + str(id))):
			get_node("WorldMap/FadeIn/" + x.name).modulate = colortemp.pop_front()

func remoteMovePressed(countrypressed , id):
	movePressedLight(countrypressed , id)
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "movePressedLight" , countrypressed , id)
	
func remoteMovePressedDark(country , id ):
	movePressedDark(country , id)
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "movePressedDark" , country , id)
			
remote func modulate(countr , color):
	get_node("WorldMap/FadeIn/" + countr).modulate = color
	
remote func modulateDark(countr , color):
	get_node("WorldMap/FadeIn/" + countr).modulate = color.darkened(0.3)

func remoteModulate(countr , color):
	modulate(countr , color)
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "modulate" , countr , color)
	
func remoteModulateDark(countr , color):
	modulateDark(countr , color)
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "modulateDark" , countr , color)

func _on_TroopsSlider_value_changed(value):
	if placeturn == true:
		$AddTroops/TroopsSlider.max_value = infantry
		$AddTroops/HMTroops.text = str(value)

func _on_DiceSlider_value_changed(value):
	$AddDice/HMDice.text = str($AddDice/DiceSlider.value)

remote func throwDice(countryattacking , countryattacked):
	changeInfo("Throw how many dice")
	if int(get_node("WorldMap/FadeIn/" + countryattacked + "/armycount").text) == 1:
		$AddDice/DiceSlider.max_value = 1
	elif int(get_node("WorldMap/FadeIn/" + countryattacked + "/armycount").text) >= 2:
		$AddDice/DiceSlider.max_value = 2
	
	var node = get_node("WorldMap/FadeIn/" + str(countryattacked))
	$AddDice.set_position(Vector2(node.get_position().x + (node.get_size().x)/2 , node.get_position().y))
	$AddDice/appear.play("appear")
	rpcsenderid = get_tree().get_rpc_sender_id()
	
func _on_OkButton_pressed():
	if rpcsenderid == null:
		$AddDice/appear.play_backwards("appear")
		while defenderdice.empty() == true:
			yield(get_tree().create_timer(0.1), "timeout")
		throwDiceAttack(int($AddDice/HMDice.text))
		compareDice()
		remoteAttackPressed(pressed , get_tree().get_network_unique_id())
		remoteModulate(pressed , mycolor)
		if int(get_node("WorldMap/FadeIn/" + pressedattack + "/armycount").text) == 0:
			territories += 1
			getcard = true
			for x in GameState.playersingame:
				if x != get_tree().get_network_unique_id():
					rpc_id(x , "changeCountryId" , get_tree().get_network_unique_id() , mycolor , pressedattack)
			changeCountryId(get_tree().get_network_unique_id() , mycolor , pressedattack)
			var node = get_node("WorldMap/FadeIn/" + str(pressedattack))
			$AddTroopsAttack.set_position(Vector2(node.get_position().x + (node.get_size().x)/2 , node.get_position().y))
			$AddTroopsAttack/AttackSliderA.min_value = int($AddDice/HMDice.text)
			$AddTroopsAttack/AttackSliderA.value = $AddTroopsAttack/AttackSliderA.min_value
			$AddTroopsAttack/AttackSliderA.max_value = int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) -1
			$AddTroopsAttack/appear.play("appear")
			
		else:
			timetoattack = false
			pressed = null
			pressedattack = null
			attackerdice.clear()
			defenderdice.clear()
			changeInfo("Your Turn")
		
	else:
		$AddDice/appear.play_backwards("appear")
		rpc_id(rpcsenderid , "throwDiceDefend" , int($AddDice/HMDice.text))
		changeInfo("Opponent's Turn")
		rpcsenderid = null
		
remote func throwDiceDefend(diceamount):
	for x in range(diceamount):
		defenderdice.append(randi() % 6 + 1)

func throwDiceAttack(diceamount):
	for x in range(diceamount):
		attackerdice.append(randi() % 6 + 1)

func compareDice():
	attackerdice.sort()
	defenderdice.sort()
	while defenderdice.empty() == false and attackerdice.empty() == false:
		if attackerdice.max() <= defenderdice.max():
			attackerdice.pop_back()
			defenderdice.pop_back()
			updateTroops(pressed , int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text)-1)
			for x in GameState.playersingame:
				if x != get_tree().get_network_unique_id():
					rpc_id(x , "updateTroops" , pressed , int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text))
		else:
			attackerdice.pop_back()
			defenderdice.pop_back()
			updateTroops(pressedattack , int(get_node("WorldMap/FadeIn/" + pressedattack + "/armycount").text)-1)
			for x in GameState.playersingame:
				if x != get_tree().get_network_unique_id():
					rpc_id(x , "updateTroops" , pressedattack , int(get_node("WorldMap/FadeIn/" + pressedattack + "/armycount").text))

remote func changeCountryId(id , colors , countrytochange):
	var tempnode = get_node("WorldMap/FadeIn/" + countrytochange)
	tempnode.modulate = colors
	if int(tempnode.get_children()[2].name) == get_tree().get_network_unique_id():
		territories = territories - 1
	tempnode.get_children()[2].name = str(id)
	
func _on_OkButtonA_pressed():
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "updateTroops" , pressed , str(int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) - int($AddTroopsAttack/HMTroopsAttack.text)))
			rpc_id(x , "updateTroops" , pressedattack , $AddTroopsAttack/HMTroopsAttack.text)
	updateTroops(pressed , str(int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) - int($AddTroopsAttack/HMTroopsAttack.text)))
	updateTroops(pressedattack , $AddTroopsAttack/HMTroopsAttack.text)
	$AddTroopsAttack/appear.play_backwards("appear")
	timetoattack = false
	pressed = null
	pressedattack = null
	attackerdice.clear()
	defenderdice.clear()
	changeInfo("Your Turn")
	
func _on_AttackSliderA_value_changed(value):
	$AddTroopsAttack/HMTroopsAttack.text = str(value)

func _on_CardHolder_pressed():
	if cardsinhand.empty() == false:
		if cardspressed == false:
			var count = int(-cardsinhand.size()/2)
			for x in $WorldMap/CardHolder/CardsInHand.get_children():
				x.set_position(Vector2(get_tree().get_root().get_size().x/2 + count*50 - (x.get_size().x)/2, 700))
				x.visible = true
				if cardsinhand.size() % 2 == 0:
					if count == -1:
						count += 2
					else:
						count += 1
				else:
					count += 1
			cardspressed = true
		else:
			for x in $WorldMap/CardHolder/CardsInHand.get_children():
				x.visible = false
			cardspressed = false
		
func getCard():
	cardsinhand.append(cards.pop_front())
	print(cardsinhand)
	$WorldMap/CardHolder/CardsInHand.add_child(get_node("Cards/" + str(cardsinhand.back())).duplicate())
	_on_CardHolder_pressed()
	_on_CardHolder_pressed()
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "updateCards" , cards)
		
remote func updateCards(updatedcards):
	cards = updatedcards

func checkCombinations():
	if cardchecked[0].get_child(0).name == cardchecked[1].get_child(0).name and cardchecked[1].get_child(0).name ==  cardchecked[2].get_child(0).name:
		$WorldMap/CardHolder/TradeIn.visible = true
	elif cardchecked[0].get_child(0).name != cardchecked[1].get_child(0).name and cardchecked[1].get_child(0).name != cardchecked[2].get_child(0).name:
		$WorldMap/CardHolder/TradeIn.visible = true
		
func _on_TradeIn_pressed():
	$WorldMap/CardHolder/TradeIn.visible = false
	infantry += infantrycards
	infantrycards += 2
	plusInfantryCards()
	queueFreeCard()
	cardchecked.clear()
	
func plusInfantryCards():
	for y in cardchecked:
		for x in $WorldMap/FadeIn.get_children():
			if x.name == y.name:
				x.get_child(0).text = str(int(x.get_child(0).text) + 2)
				return

func queueFreeCard():
	for y in cardchecked:
		for x in $WorldMap/CardHolder/CardsInHand.get_children():
			if x.name == y.name:
				x.queue_free()

func addInfantry(amount):
	infantry = infantry + amount

func _on_MovekSliderM_value_changed(value):
	$AddTroopsMove/HMTroopsMove.text = str(value)
	
func _on_OkButtonM_pressed():
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "updateTroops" , pressed , int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) - int($AddTroopsMove/HMTroopsMove.text))
	updateTroops(pressed , int(get_node("WorldMap/FadeIn/" + pressed + "/armycount").text) - int($AddTroopsMove/HMTroopsMove.text))
			
	for x in GameState.playersingame:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "updateTroops" , pressedmove , int(get_node("WorldMap/FadeIn/" + pressedmove + "/armycount").text) + int($AddTroopsMove/HMTroopsMove.text))
	updateTroops(pressedmove , int(get_node("WorldMap/FadeIn/" + pressedmove + "/armycount").text) + int($AddTroopsMove/HMTroopsMove.text))
	$AddTroopsMove/appear.play_backwards("appear")
	remoteModulate(pressed , mycolor)
	remoteMovePressed(pressed , get_tree().get_network_unique_id())
	pressed = null
	pressedmove = null
	movingdone = true
	
