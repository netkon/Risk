extends Node

var readyamount = []
var pressed
var startpressed
var gamehasstarted
var timer

func _ready():
	timer = 0
	gamehasstarted = false
	startpressed = false
	pressed = false

	
func _input(event):
	
	if $Panel/LeaveLobby.is_pressed():
		get_node("/root/Lobby/LobbyNames").visible = false
		get_node("/root/Lobby/CreateGame").visible = false
		get_node("/root/Lobby/Host").visible = true
		get_node("/root/Lobby/Join").visible = true

		if get_tree().get_network_unique_id() == int(GameState.currentroominfo["gamehost"]):
			
			if GameState.gameroom.size() > 1:
				get_node("/root/Lobby").updateCurrentPlayersC(GameState.gameroompos , GameState.gameroom.size() - 1)
				for x in GameState.gameroom:
					if x != get_tree().get_network_unique_id():
						rpc_id(x , "changeGameHost" , get_tree().get_network_unique_id())						
				removeLobbyPlayer(get_tree().get_network_unique_id())
				
			elif GameState.gameroom.size() == 1:
				get_tree().get_root().get_node("Lobby").deleteRoomList(GameState.listofgamesnames[GameState.gameroompos]["position"] , true)
				removeLobbyPlayer(get_tree().get_network_unique_id())
				
			
		else:
			get_node("/root/Lobby").updateCurrentPlayersC(GameState.gameroompos , GameState.gameroom.size() - 1)
			for x in GameState.gameroom:
				if x != get_tree().get_network_unique_id():
					rpc_id(x , "removeLobbyPlayer" , get_tree().get_network_unique_id())
					yield(get_tree().create_timer(0.3), "timeout")
			removeLobbyPlayer(get_tree().get_network_unique_id())

		
	if $Panel/ReadyButton.is_pressed() and pressed == false:
		if get_tree().get_network_unique_id() == GameState.currentroominfo["gamehost"]:
			plusOne(get_tree().get_network_unique_id())
			pressed = true
			$Panel/ReadyButton.text = "Unready"
		else:
			rpc_id(GameState.currentroominfo["gamehost"], "plusOne" , get_tree().get_network_unique_id())
			pressed = true
			$Panel/ReadyButton.text = "Unready"
	
	elif $Panel/ReadyButton.is_pressed() and pressed == true:
		if get_tree().get_network_unique_id() == GameState.currentroominfo["gamehost"]:
			minusOne(get_tree().get_network_unique_id())
			pressed = false
			$Panel/ReadyButton.text = "Ready"
		else:
			rpc_id(GameState.currentroominfo["gamehost"] , "minusOne" , get_tree().get_network_unique_id())
			pressed = false
			$Panel/ReadyButton.text = "Ready"
			
	if $Panel/StartGame.pressed == true and startpressed == false:
		$Panel/Timer.start(4)
		startpressed = true
		$Panel/StartGame.text = "Stop Start"
			
	elif $Panel/StartGame.pressed == true and startpressed == true:
		$Panel/Timer.stop()
		startpressed = false
		$Panel/StartGame.text = "Start Game"
		
func _process(delta):
	if GameState.gameroom.find(get_tree().get_network_unique_id()) != -1:
		$Panel/PlayersReady.text = "Players ready : " + str(readyamount.size()) + "/" + str(GameState.currentroominfo["nofplayers"])
		
		if get_tree().get_network_unique_id() == GameState.currentroominfo["gamehost"]:
			for z in GameState.gameroom:
				if z != get_tree().get_network_unique_id():
					rpc_id(z , "sendInfo" , readyamount)
				sendInfo(readyamount)
				
				if startpressed == true:
					if z != get_tree().get_network_unique_id():
						rpc_id(z , "updateTimer" , str($Panel/Timer.time_left))
					else :
						updateTimer(str(int($Panel/Timer.time_left)))		
											
			if readyamount.size() >= 2:
				$Panel/StartGame.visible = true
			
			if stepify($Panel/Timer.time_left , 0.1) == 0.5 and gamehasstarted == false:
				gamehasstarted = true
				GameState.startGame(readyamount)
					
		if readyamount.size() < 2:
			$Panel/StartGame.visible = false
			$Panel/Timer.stop()
			$Panel/Timer/TimeLeft.visible = false
			startpressed = false
			$Panel/StartGame.text = "Start Game"
			
		else:
			if stepify(float(timer) , 0.1) == 0.5 and gamehasstarted == false:
				gamehasstarted = true
				get_tree().get_root().get_node("Lobby").deleteRoomList(GameState.listofgamesnames[GameState.gameroompos]["position"] , false)
				GameState.startGame(readyamount)	
						
remote func plusOne(id):
	readyamount.append(id)	
				
remote func minusOne(id):
	readyamount.erase(id)	
	
remote func sendInfo(info):
	readyamount = info
	
remote func removeLobbyPlayer(id): # esta funcao vai remover os dados do jogador sai do lobby
	if id == get_tree().get_network_unique_id():
		get_tree().get_root().get_node("PreGame").queue_free()
		GameState.gameroom.clear() 
		GameState.currentroominfo["gamehost"] = ""
		GameState.currentroominfo["nofplayers"] = ""
	else:
		GameState.gameroom.erase(id)		
		get_tree().get_root().get_node("PreGame/" +str(id)).queue_free()
	
remote func changeGameHost(id):
	removeLobbyPlayer(id)
	GameState.currentroominfo["gamehost"] = GameState.gameroom.front()
	if GameState.currentroominfo["gamehost"] == get_tree().get_network_unique_id():
		get_tree().get_root().get_node("Lobby").changeRoomName(GameState.listofgamesnames[GameState.gameroompos]["position"], get_tree().get_network_unique_id() , GameState.playername , GameState.listofgamesnames[GameState.gameroompos]["gamename"], GameState.currentroominfo["nofplayers"] ,false)
				
remotesync func updateTimer(time):
	timer = time
	$Panel/Timer/TimeLeft.visible = true
	$Panel/Timer/TimeLeft.text = str(int(time))
				
