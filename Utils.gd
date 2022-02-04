extends Node

func zx(v: Vector3) -> Vector2:
	return Vector2(v.z, v.x)

func zy(v: Vector3) -> Vector2:
	return Vector2(v.z, v.y)
	
func zx2xyz(v: Vector2, y: float = 0.0) -> Vector3:
	return Vector3(v.y, y, v.x)
	
func zy2xyz(v: Vector2, x: float = 0.0) -> Vector3:
	return Vector3(v.y, v.x, x)
	
func assign_zx(v: Vector3, zx: Vector2) -> Vector3:
	return zx2xyz(zx, v.y)

func assign_zy(v: Vector3, zy: Vector2) -> Vector3:
	return zy2xyz(zy, v.x)
