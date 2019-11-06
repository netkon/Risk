extends Node2D

var playerNumber = chooseFirstPlayer()

####################################################### Função para atacar ####################################################
func attack(attackerRegion , defenderRegion):
	if canAttack:
		if activePlayer != defenderRegion.getOwner && defenderRegion.getOwner() != 0: # ver se a regiao esta ocupada
			if verifyNeighbor(attackerRegion , defenderRegion) == true: # verificar se a regiao e' vizinha da outra
				#Atacante e defensor lançam os dados .. atacante 1-3 dados .. defensor 1-2 dados
				#comparase o maximo dos dados do atacante com o maximo dos dados do defensor
				# por cada "dado ganho" mata uma tropa, por cada perdido perder uma tropa
				#quando o ataque a acabar volta ao menu de escolher entre atacar ou passar o turno
				#se voltar a atacar chama outra vez a funcao attack
				# se mudar o turno chama a funcao pra passar de turno
				if attackerRegion.armyCount <= 1:
					print("can't atack")
					attack()
				else:
	# Pergunta ao utilizador se quer atacar com 1, 2 ou 3 e ao defensor 1 ou 2 exercitos #attackArmyCount #defendArmyCount
					if attackerRegion.armyCount <= attackArmyCount:
						print("You need more troops in order to attack hommie!")
						attack()
						if defenderRegion.armyCount < defendArmyCount:
							print("You need more troops in order to defend hommie!")
							defend()
						else:
							if attackArmyCount == 1 && defendArmyCount == 1:
								attacker.FirstDice = dice()
								defender.FirstDice = dice()
								if attacker.FirstDice > defender.FirstDice:
									defenderRegion.armyCount = defenderRegion.armyCount - 1
								else:
									attackerRegion.armyCount = attackerRegion.armyCount - 1
							if attackArmyCount == 1 && defendArmyCount == 2:
								attacker.FirstDice = dice()
								defender.FirstDice = dice()
								defender.SecondDice = dice()
								if attacker.FirstDice > max(defender.FirstDice, defender.SecondDice):
									defenderRegion.armyCount = defenderRegion.armyCount - 1
								else:
									attackerRegion.armyCount = attackerRegion.armyCount - 1
							if attackArmyCount == 2 && defendArmyCount == 1:
								attacker.FirstDice = dice()
								defender.FirstDice = dice()
								attacker.SecondDice = dice()
								if max(attacker.FirstDice, attacker.SecondDice) > defender.FirstDice:
									defenderRegion.armyCount = defenderRegion.armyCount - 1
								else:
									attackerRegion.armyCount = attackerRegion.armyCount - 1
							elif attackArmyCount == 2 && defendArmyCount == 2:
								attacker.FirstDice = dice()
								defender.FirstDice = dice()
								attacker.SecondDice = dice()
								defender.SecondDice = dice()
								if max(attacker.FirstDice, attacker.SecondDice) > max(defender.FirstDice, defender.SecondDice):
									if min(attacker.FirstDice, attacker.SecondDice) > min(defender.FirstDice, defender.SecondDice):
										defenderRegion.armyCount = defenderRegion.armyCount - 2
									else:
										attackerRegion.armyCount = attackerRegion.armyCount - 1
										defenderRegion.armyCount = defenderRegion.armyCount - 1
								else:
									attackerRegion.armyCount = attackerRegion.armyCount - 2
							elif attackArmyCount == 3 && defendArmyCount == 2:
								attacker.FirstDice = dice()
								defender.FirstDice = dice()
								attacker.SecondDice = dice()
								defender.SecondDice = dice()
								attacker.ThirdDice = dice()
								if max(attacker.FirstDice, attacker.SecondDice, attacker.ThirdDice) > max(defender.FirstDice, defender.SecondDice):
									if median(attacker.FirstDice, attacker.SecondDice, attacker.ThirdDice) > min(defender.FirstDice, defender.SecondDice):
										defenderRegion.armyCount = defenderRegion.armyCount - 2
									else:
										attackerRegion.armyCount = attackerRegion.armyCount - 1
										defenderRegion.armyCount = defenderRegion.armyCount - 1
								else:
									attackerRegion.armyCount = attackerRegion.armyCount - 2
							elif attackArmyCount == 3 && defendArmyCount == 1:
								attacker.FirstDice = dice()
								defender.FirstDice = dice()
								attacker.SecondDice = dice()
								attacker.ThirdDice = dice()
								if max(attacker.FirstDice, attacker.SecondDice, attacker.ThirdDice) > defender.FirstDice:
									defenderRegion.armyCount = defenderRegion.armyCount - 1
								else:
									attackerRegion.armyCount = attackerRegion.armyCount - 1
################################################# Fim da função para atacar ###################################################								
	


func _ready():




	#pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

