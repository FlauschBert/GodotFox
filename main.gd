extends Node2D

@onready var _camera = $Camera3D

# size of SubViewport
const _screenSize: Vector2i = Vector2i(320, 256)

# use right-hand-coordinate-system (cw)
var _triangles: Array[int] = [
	# bottom
	# side a
	-50, 0, 0, 50, 0, 0,
	# side b
	50, 0, 0, 0, 0, 50,
	# side c
	0, 0, 50, -50, 0, 0,
	
	# side a
	50, 0, 0, -50, 0, 0,
	-50, 0, 0, 0, 50, 50,
	0, 50, 50, 50, 0, 0,
	
	# side b
	0, 0, 50, 50, 0, 0,
	50, 0, 0, 0, 50, 50,
	0, 50, 50, 0, 0, 50,
	
	# side c
	-50, 0, 0, 0, 0, 50,
	0, 0, 50, 0, 50, 50,
	0, 50, 50, -50, 0, 0
]

var _colors: Array = [Color.CHARTREUSE, Color.DARK_ORANGE, Color.FOREST_GREEN, Color.AQUAMARINE]

var _angles: Vector3 = Vector3.ZERO

var _projection: Projection = Projection.IDENTITY

var _rotate: bool = true


func rotatePnt(pnt: Vector3, angles: Vector3) -> Vector3:
	pnt = pnt.rotated(Vector3.RIGHT, deg_to_rad(angles.x))
	pnt = pnt.rotated(Vector3.UP, deg_to_rad(angles.y))
	pnt = pnt.rotated(Vector3.BACK, deg_to_rad(angles.z))
	return pnt


func projectAndMovePnt(pnt: Vector3, projection: Projection, screenSize: Vector2i) -> Vector2i:
	var pnt4 = Vector4(pnt.x, pnt.y, pnt.z, 0.0) * projection
	return Vector2i(pnt4.x + screenSize.x/2.0, pnt4.y + screenSize.y/2.0)


func nextPnt(index: int, pnts: Array[int]) -> Vector3:
	var pnt = Vector3(
		pnts[index + 0],
		pnts[index + 1],
		pnts[index + 2],
	)
	return pnt


func _ready():
	_projection = _camera.get_camera_projection()


func drawLine(index: int, array: Array[int]):
	var p1: Vector3 = nextPnt(index, array)
	index += 3
	var p2: Vector3 = nextPnt(index, array)
	
	p1 = rotatePnt(p1, _angles)
	p2 = rotatePnt(p2, _angles)
	
	var p1_2i: Vector2i = projectAndMovePnt(p1, _projection, _screenSize)
	var p2_2i: Vector2i = projectAndMovePnt(p2, _projection, _screenSize)
	
	draw_line(p1_2i, p2_2i, Color.AZURE)


func isTriangleVisible(p1: Vector2, p2: Vector2, p3: Vector2) -> bool:
	# straight-forward:
	#
	# 	var v1: Vector3 = p2 - p1
	# 	var v2: Vector3 = p3 - p2
	# 	return v1.cross(v2).z > 0
	
	# optimized
	#
	# 	cross-z: v1.x * v2.y - v1.y * v2.x
	
	var v1: Vector2 = p2 - p1
	var v2: Vector2 = p3 - p2
	return v1.x * v2.y - v1.y * v2.x > 0
	

func drawTriangles():
	var array: Array[int] = _triangles
	var color: int = -1
	var index = 0
	while index < array.size():
		var linesIndex = index
		
		var p1: Vector3 = nextPnt(index, array)
		index += 6
		var p2: Vector3 = nextPnt(index, array)
		index += 6
		var p3: Vector3 = nextPnt(index, array)
		index += 6
		
		p1 = rotatePnt(p1, _angles)
		p2 = rotatePnt(p2, _angles)
		p3 = rotatePnt(p3, _angles)
		
		color += 1
		
		if not isTriangleVisible(Vector2(p1.x, p1.y), Vector2(p2.x, p2.y), Vector2(p3.x, p3.y)):
			continue
		
		var p1_2i: Vector2i = projectAndMovePnt(p1, _projection, _screenSize)
		var p2_2i: Vector2i = projectAndMovePnt(p2, _projection, _screenSize)
		var p3_2i: Vector2i = projectAndMovePnt(p3, _projection, _screenSize)
		
		draw_colored_polygon([p1_2i, p2_2i, p3_2i], _colors[color])
		
		drawLine(linesIndex, array)
		linesIndex += 6
		drawLine(linesIndex, array)
		linesIndex += 6
		drawLine(linesIndex, array)
		linesIndex += 6


func _draw():
	drawTriangles()


func _process(_delta):
	if not _rotate:
		return
		
	_angles += Vector3(1.0, 3.0, 2.0) * 0.5
	queue_redraw()


func _input(event):
	if event.is_action_pressed("PAUSE"):
		_rotate = not _rotate
