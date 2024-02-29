class_name VisibleCollisionPolygon2D extends CollisionPolygon2D

@export var color: Color = "00b3306b"
@export var visible_by_default: bool = false
var visible_poly: Polygon2D


func _ready() -> void:
	visible = visible_by_default
	visible_poly = Polygon2D.new()
	visible_poly.polygon = polygon
	visible_poly.color = color
	#visible_poly.antialiased = true
	add_child(visible_poly)
