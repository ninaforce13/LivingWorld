extends Spatial

var point_collection = {}
var astar
var gridmap

func _ready():
	gridmap = get_parent().get_node("GridMap")
	astar = AStar.new()
	var cells = gridmap.get_used_cells()
	for cell in cells:
		var point_id = astar.get_available_point_id()
		astar.add_point(point_id, gridmap.map_to_world(cell.x,cell.y,cell.z))
		point_collection[get_vec3_index(cell)] = point_id
	for cell in cells:
		for x in [-1,0,1]:
			for y in [-1,0,1]:
				for z in [-1,0,1]:
					var vec3 = Vector3(x,y,z)
					if vec3 == Vector3(0,0,0):
						continue
					if get_vec3_index(vec3) in point_collection:
						var point_id1 = point_collection[get_vec3_index(cell)]
						if not get_vec3_index(cell + vec3) in point_collection:
							continue
						var point_id2 = point_collection[get_vec3_index(cell + vec3)]
						if !astar.are_points_connected(point_id1,point_id2):
							astar.connect_points(point_id1,point_id2)

func get_astar_path(start, end):
	var start_index = get_vec3_index(gridmap.world_to_map(start))
	var end_index = get_vec3_index(gridmap.world_to_map(end))
	var start_point_id = 0
	var end_point_id = 0
	
	if start_index in point_collection:
		start_point_id = point_collection[start_index]
	else:
		start_point_id = astar.get_closest_point(start)
	
	if end_index in point_collection:
		end_point_id = point_collection[end_index]
	else:
		end_point_id = astar.get_closest_point(end)
	
	return astar.get_point_path(start_point_id, end_point_id)
	

func get_vec3_index(vec3):
	return "%s,%s,%s"%[str(int(round(vec3.x))), str(int(round(vec3.y))), str(int(round(vec3.z)))]
