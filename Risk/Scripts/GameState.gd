extends Node

const PORT = 5000
const SERVERPORT = 5006
#nome do jogador
var playername
#coisas a ver com a gameroom
var gameroom = []
#informacao de cada sala de jogos , contem os ids de cada jogador
var currentroominfo = {"gamehost" : "" ,"nofplayers" : ""} 

var listofgamesnames = [] # lista da representacao dos hosts de jogo que estao no LobbyNames
var waiting
#todos os jogadores que estao no servidor
var serverplayers = []
var client
var playersingame = []
var gameroompos

func _process(delta):
	pass
	
func _ready():
	randomize()
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected" , self , "_player_disconnected")
	get_tree().connect("server_disconnected" , self , "_server_disconnected")
	
	
func _server_disconnected():
	print("server ded")	
	get_tree().quit()
	#get_tree().get_root().get_node("Lobby/Panel").visible = true
	#get_tree().get_root().get_node("Lobby/ConnectButton").visible = true
	
func _player_connected(id):	
	print(str(id) + "has connected")
	rpc("registerPlayer" , id)
	registerPlayer(id)
	print(serverplayers)
		
func _player_disconnected(id):
	if gameroom.find(id) != -1:
		GameState.gameroom.erase(id)		
		get_tree().get_root().get_node("PreGame/" +str(id)).queue_free()
	
	serverplayers.erase(id)
	print(str(id) + " has disconnected")

func joinGame():
	var waitingroom = load("res://WaitingRoom.tscn").instance()
	get_tree().get_root().add_child(waitingroom)
	
func hostGame(nofplayers):
	currentroominfo["gamehost"] = get_tree().get_network_unique_id()
	currentroominfo["nofplayers"] = nofplayers
	print(currentroominfo)
	gameroom.append(get_tree().get_network_unique_id())
	var waitingroom = load("res://WaitingRoom.tscn").instance()
	get_tree().get_root().add_child(waitingroom)
	createPlayer(get_tree().get_network_unique_id())

	

func startCORS():
	
	var noretrys = 0
	client = NetworkedMultiplayerENet.new()
	client.create_client( IP.get_local_addresses()[9] , SERVERPORT)
	get_tree().set_network_peer(client)
	
	if client.get_connection_status() == client.CONNECTION_CONNECTED:
		pass	
	elif client.get_connection_status() == client.CONNECTION_CONNECTING:
		while (client.get_connection_status() == client.CONNECTION_CONNECTING) and (noretrys < 11):
			yield(get_tree().create_timer(0.1), "timeout")
			noretrys +=1
				
	if (client.get_connection_status() == client.CONNECTION_CONNECTING) and (noretrys >= 11):
		
		var server = NetworkedMultiplayerENet.new()
		server.create_server(SERVERPORT , 10)
		get_tree().set_network_peer(server)	

func createPlayer(id):
	var player = preload("res://Player.tscn").instance()
	player.name = str(id)
	player.set_network_master(id)
	get_tree().get_root().get_node("PreGame").add_child(player)

func startGame(players):
	playersingame = players
	var game = preload("res://Risk.tscn").instance()
	game.name = str("Risk")
	game.set_network_master(get_tree().get_network_unique_id())
	get_tree().get_root().add_child(game)
	print("players in game" + str(playersingame))
	#get_node("/root/Lobby").queue_free()
	#get_node("/root/PreGame").queue_free()

	print("Game Has Started")
	pass
	
remote func registerPlayer(id):
	if serverplayers.find(id) == -1:
		serverplayers.append(id)		
	
