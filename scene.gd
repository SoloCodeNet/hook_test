extends Node2D
onready var tm = $TileMap
onready var player = $player
onready var visor   = $visor
var hook : bool


func hooked(value):
	hook = value

func _process(delta: float) -> void:
	if hook:
		var pool:PoolVector2Array=[]
		pool.append(player.global_position)
		pool.append(visor.global_position)
		$line.points = pool
	else:
		$line.points = []
		
func light_tile(pos) -> Vector2:
	reset()
	var tl = tm.world_to_map(pos)
	if tm.get_cellv(tl) == 0:
		tm.set_cellv(tl, 2)
		return tm.map_to_world(tl)+ Vector2(8,8)
	else:
		return Vector2.ZERO
		
func reset():
	for xy in tm.get_used_cells_by_id(2):
		tm.set_cellv(xy, 0)
	