class_name BorderLine2D extends Line2D

enum Kind {
	Red,
	Green,
	Blue
}
@export var color: Kind = Kind.Blue
var target_group: CanvasGroup

func _ready() -> void:
	joint_mode = Line2D.LINE_JOINT_ROUND
	antialiased = true
	closed = true
	
	#region Physics
	var body: StaticBody2D = StaticBody2D.new()
	add_child(body)
	
	var size: int = get_point_count() - 1
	for i in range(size):
		var collider: CollisionShape2D = CollisionShape2D.new()
		collider.shape = SegmentShape2D.new()
		collider.shape.a = points[i]
		collider.shape.b = points[i + 1]
		body.add_child(collider)
	
	var closing_collider: CollisionShape2D = CollisionShape2D.new()
	closing_collider.shape = SegmentShape2D.new()
	closing_collider.shape.a = points[size]
	closing_collider.shape.b = points[0]
	body.add_child(closing_collider)
	#endregion
	
	#region Stripes
	match color:
		Kind.Red:
			target_group = get_tree().get_first_node_in_group("canvas_red_stripes") as CanvasGroup
		Kind.Green:
			target_group = get_tree().get_first_node_in_group("canvas_green_stripes") as CanvasGroup
		Kind.Blue:
			target_group = get_tree().get_first_node_in_group("canvas_blue_stripes") as CanvasGroup
	var polygon_stripes: Polygon2D = Polygon2D.new()
	polygon_stripes.polygon = points
	target_group.add_child(polygon_stripes)
	#endregion
