extends Node

var hasconnected = false

var gamesnames = {"id" : "" , "playername" : "" , "gamename" : "" , "nofplayers" : "" , "position" : "" , "currentplayers" : ""}

var timecheck

func _ready():
	timecheck = 0
	
func _process(delta):
	if hasconnected:
		if get_tree().is_network_server():
			timecheck += delta
			if stepify(timecheck , 0.1) == 0.5:
				timecheck = 0
				rpc("sendInfoLobby" , GameState.listofgamesnames)
				
				

					
				
func _input(event):
	for i in GameState.listofgamesnames.size():
		if has_node("LobbyNames/" + str(GameState.listofgamesnames[i]["gamename"])):
			if get_node("LobbyNames/" + str(GameState.listofgamesnames[i]["gamename"]) + "/Button").pressed == true:#verificar qual botao da room list
				
				if int(GameState.listofgamesnames[i]["nofplayers"]) == int(GameState.listofgamesnames[i]["currentplayers"]):
					pass
				else:	
					GameState.currentroominfo["gamehost"] = GameState.listofgamesnames[i]["id"]  #colocar nos clientes quem é o roomhost	
					rpc_id(GameState.listofgamesnames[i]["id"], "sendInfoGameRoom" , get_tree().get_network_unique_id()) # mandar informacao para o dono da sala, nao o server
					GameState.joinGame()

	
	
	
func _on_Join_pressed():
	$LobbyNames/AnimationPlayer.play("New Anim")
	$LobbyNames.visible = true
	yield(get_tree().create_timer(0.3), "timeout")
	$Join.visible = false
	$Host.visible = false

func _on_Host_pressed():
	$CreateGame/AnimationPlayer.play("Anim2")
	$CreateGame.visible = true
	yield(get_tree().create_timer(0.15), "timeout")
	$Join.visible = false
	$Host.visible = false

func _on_ExitLobbyNames_pressed():
	$LobbyNames/AnimationPlayer.play_backwards("New Anim")
	$Join.visible = true
	$Host.visible = true
	
	yield(get_tree().create_timer(0.15), "timeout")
	$LobbyNames.visible = false

func _on_ExitLobbyNames2_pressed():
	$CreateGame/AnimationPlayer.play_backwards("Anim2")
	$Join.visible = true
	$Host.visible = true
	yield(get_tree().create_timer(0.15), "timeout")
	$LobbyNames.visible = false

func _on_ConnectButton_pressed():
	if $ConnectButton/ChooseYourName.text != '' and $ConnectButton/ChooseYourName.text.length() < 10:
		GameState.playername = $ConnectButton/ChooseYourName.text 
		GameState.startCORS()
		hasconnected = true	
		$ConnectButton.disabled = true
		$ConnectButton/ChooseYourName.editable = false
		yield(get_tree().create_timer(1.5), "timeout")
		$ConnectButton.visible = false
		$Join.visible = true
		$Host.visible = true
		
func _on_CreateServerButton_pressed():
	if $CreateGame/Label/GameName.text != '' and $CreateGame/Label/GameName.text.length() <= 10:
		if $CreateGame/Label1/NOfPlayers.text != '' and $CreateGame/Label1/NOfPlayers.text.is_valid_integer() and  $CreateGame/Label1/NOfPlayers.text.to_int () <= 6 and $CreateGame/Label1/NOfPlayers.text.to_int() >= 2 :
			GameState.hostGame($CreateGame/Label1/NOfPlayers.text)
			get_node("/root/PreGame/Panel/LeaveLobby").visible = false
			if get_tree().is_network_server():
				setLobbyListVariables(GameState.listofgamesnames.size() , get_tree().get_network_unique_id() , GameState.playername , $CreateGame/Label/GameName.text , $CreateGame/Label1/NOfPlayers.text ,true)
			else:
				rpc_id(1 , "setLobbyListVariables" , GameState.listofgamesnames.size() , get_tree().get_network_unique_id() , GameState.playername , $CreateGame/Label/GameName.text , $CreateGame/Label1/NOfPlayers.text ,true)
	
			yield(get_tree().create_timer(1), "timeout")
			get_node("/root/PreGame/Panel/LeaveLobby").visible = true
			
			for x in GameState.listofgamesnames.size():
				if GameState.listofgamesnames[x]["id"] == get_tree().get_network_unique_id():
					GameState.gameroompos = GameState.listofgamesnames[x]["position"]
			
			if get_tree().is_network_server():
				updateCurrentPlayersS(GameState.listofgamesnames[GameState.gameroompos]["position"],GameState.gameroom.size())
			else:
				rpc_id(1 , "updateCurrentPlayersS" , GameState.listofgamesnames[GameState.gameroompos]["position"],GameState.gameroom.size())
	
func deleteRoomList(position , queuefree):
	if get_tree().is_network_server():
		removeOne(position)
	else:
		rpc_id( 1 , "removeOne" , position)
	
	if queuefree == true:
		get_node("/root/Lobby/LobbyNames/" + GameState.listofgamesnames[position]["gamename"]).queue_free()
	GameState.listofgamesnames.remove(position)
	rpc("removeRoomList" , position)
	

remote func removeOne(position):
	for x in GameState.listofgamesnames.size():
		if GameState.listofgamesnames[x]["position"] > position:
			GameState.listofgamesnames[x]["position"] = GameState.listofgamesnames[x]["position"] - 1
			rpc_id(GameState.listofgamesnames[x]["id"] , "updateGameRoomPosS" , GameState.listofgamesnames[x]["position"])


remote func removeRoomList(position):
	get_node("/root/Lobby/LobbyNames/" + GameState.listofgamesnames[position]["gamename"]).queue_free()
	GameState.listofgamesnames.remove(position)
	
remote func updateGameRoomPosS(position):
	for x in GameState.gameroom:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "updateGameRoomPosC" , position)
	updateGameRoomPosC(position)
	
remote func updateGameRoomPosC(position):
		GameState.gameroompos = position
		
func updateCurrentPlayersC(position , currentplayers):
	if get_tree().is_network_server():
		updateCurrentPlayersS(position , currentplayers)
	else:
		rpc_id(1 , "updateCurrentPlayersS" , position , currentplayers)

remote func updateCurrentPlayersS(position , currentplayers):
	GameState.listofgamesnames[position]["currentplayers"] = currentplayers
		
func changeRoomName(position , id , playername , gamename , nofplayers ,  new ):
	if get_tree().is_network_server():
		setLobbyListVariables(position, id , playername , gamename, nofplayers  ,false)
	else:
		rpc_id(1, "setLobbyListVariables" , position, id , playername , gamename, nofplayers  , false)
		
remote func setLobbyListVariables(position , id , playername , gamename , nofplayers  , new):
	if new == true:	
		gamesnames["position"] = position
		gamesnames["id"] = id
		gamesnames["playername"] = playername
		gamesnames["gamename"] = gamename
		gamesnames["nofplayers"] = nofplayers
		gamesnames["currentplayers"] = 1
		GameState.listofgamesnames.append(gamesnames.duplicate())
		gamesnames.clear()
		
	else:
		GameState.listofgamesnames[position]["id"] = id
		GameState.listofgamesnames[position]["playername"] = playername
		GameState.listofgamesnames[position]["gamename"] = gamename
		GameState.listofgamesnames[position]["nofplayers"] = nofplayers

remotesync func sendInfoLobby(list):
	GameState.listofgamesnames = list
	for x in GameState.listofgamesnames.size():
		if !has_node("/root/Lobby/LobbyNames/" + GameState.listofgamesnames[x]["gamename"]):
			var offset = Vector2(20, 70+ (GameState.listofgamesnames.size()-1)*45)
			var s = $LobbyNames/GameName.duplicate(1)
			get_tree().get_root().get_node("Lobby/LobbyNames").add_child(s)
			s.set_position(offset)
			s.name = str(GameState.listofgamesnames[x]["gamename"])
			s.text = GameState.listofgamesnames[x]["gamename"]
			s.get_node("PlayerName").text = GameState.listofgamesnames[x]["playername"]
			s.get_node("Label").text = str(1) + "/" + GameState.listofgamesnames[x]["nofplayers"]
			s.visible = true
		else:
			get_node("/root/Lobby/LobbyNames/" + str(GameState.listofgamesnames[x]["gamename"]) + "/PlayerName").text = GameState.listofgamesnames[x]["playername"]
			get_node("/root/Lobby/LobbyNames/" + str(GameState.listofgamesnames[x]["gamename"]) + "/Label").text = str(GameState.listofgamesnames[x]["currentplayers"]) + "/" + GameState.listofgamesnames[x]["nofplayers"]
			var offset2 = Vector2(20 , 70 + float(GameState.listofgamesnames[x]["position"])*45)
			get_node("/root/Lobby/LobbyNames/" + str(GameState.listofgamesnames[x]["gamename"])).set_position(offset2)			
			
remote func sendInfoGameRoom(i): #colocar informacao sobre os jogadores no host para mandar para os outros
	GameState.createPlayer(i)
	GameState.gameroom.append(i)
	
	if get_tree().is_network_server():
		updateCurrentPlayersS(GameState.listofgamesnames[GameState.gameroompos]["position"],GameState.gameroom.size())
	else:
		rpc_id(1 , "updateCurrentPlayersS" , GameState.listofgamesnames[GameState.gameroompos]["position"] , GameState.gameroom.size())
	
	for x in GameState.gameroom:
		if x != get_tree().get_network_unique_id():
			rpc_id(x , "updateGameRoom" , GameState.gameroom , GameState.currentroominfo , GameState.gameroompos)
	
remote func updateGameRoom(infogameroomnames , infogameroomhost , position): # atualizar a informacao dos clientes com a gameroom do host
	GameState.gameroompos = position
	GameState.gameroom = infogameroomnames
	GameState.currentroominfo = infogameroomhost
	for x in GameState.gameroom:
		if has_node("/root/PreGame/" + str(x)) == false:
			GameState.createPlayer(x)

