extends Node

# Declare member variables here. Examples:
# var a = 2
# var b = "text
var countries = []
func _input(event):
	if $WorldMap/GreatBritain.pressed == true:
		$WorldMap/GreatBritain.modulate = Color(0 , 250 , 0 , 1)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var s = RandomNumberGenerator.new()

	
	for x in $WorldMap.get_children():
		countries.append(x.name)
		x.modulate = Color(0 , 250 , 0 , 1)
		
	for x in countries:
		print(s.randi_range(0 , countries.size()))
		
		
func gameStart():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
