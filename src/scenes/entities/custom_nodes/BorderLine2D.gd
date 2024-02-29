class_name BorderLine2D extends Line2D


func _ready() -> void:
	joint_mode = Line2D.LINE_JOINT_ROUND
	antialiased = true
	closed = true
	
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

