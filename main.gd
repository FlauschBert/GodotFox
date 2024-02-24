extends TextureRect

@onready var _camera = $Camera3D

const _screenSize: Vector2i = Vector2i(480, 270)

var _linePnts: Array[int] = [
	# RUMPF
	-50,  0,  0, 50,  0, 40,
	 50,  0, 40, 50,  3,  6,
	-50,  0,  0, 50,  0,-40,

		 50,  0, 40, 50, -3,  6
   ,      50,  3,  6, 50, -3,  6

   ,     -50,  0,  0, 50,  3,  6
   ,     -50,  0,  0, 50, -3,  6

   ,     -50,  0,  0, 50,  3, -6
   ,     -50,  0,  0, 50, -3, -6

   ,      50,  0,-40, 50,  3, -6
   ,      50,  0,-40, 50, -3, -6
   ,      50,  3, -6, 50, -3, -6
   ,      50,  3, -6, 50,  3,  6
   ,      50, -3, -6, 50, -3,  6

	#              *******   COCKPIT  *******

	,      -36,  2,  0,-18,  1,  2
	,      -36,  2,  0,-18,  4,  0
	,      -36,  2,  0,-18,  1, -2

	,      -18,  1,  2,-18,  4,  0
	,      -18,  1, -2,-18,  4,  0

	,        0,  2,  0,-18,  1,  2
	,        0,  2,  0,-18,  1, -2
	,        0,  2,  0,-18,  4,  0

#              **** LEITWERK ********

	,       14,  1, 20, 50, 11, 28
	,       14,  1, 20, 50,  1, 20
	,       50, 11, 28, 50,  1, 20

	,       14,  1,-20, 50, 11,-28
	,       14,  1,-20, 50,  1,-20
	,       50, 11,-28, 50,  1,-20
]

var _angles: Vector3 = Vector3.ZERO

var _projection: Projection = Projection.IDENTITY



func rotate(pnt: Vector3, angles: Vector3) -> Vector3:
	pnt = pnt.rotated(Vector3.RIGHT, deg_to_rad(angles.x))
	pnt = pnt.rotated(Vector3.UP, deg_to_rad(angles.y))
	pnt = pnt.rotated(Vector3.BACK, deg_to_rad(angles.z))
	return pnt


func projectAndMove(pnt: Vector3, projection: Projection, screenSize: Vector2i) -> Vector2i:
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


func _draw():
	var index = 0
	while index < _linePnts.size():
		var p1: Vector3 = nextPnt(index, _linePnts)
		index += 3
		var p2: Vector3 = nextPnt(index, _linePnts)
		index += 3
		
		p1 = rotate(p1, _angles)
		p2 = rotate(p2, _angles)
		
		var p1_2i: Vector2i = projectAndMove(p1, _projection, _screenSize)
		var p2_2i: Vector2i = projectAndMove(p2, _projection, _screenSize)
		
		draw_line(p1_2i, p2_2i, Color.CADET_BLUE)


func _process(_delta):
	_angles += Vector3(1.0, 3.0, 2.0)
	queue_redraw()
