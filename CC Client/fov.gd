extends Light2D

onready var tween = get_node("Tween")

#func _ready():
#	$"..".connect("direction_changed", self, '_on_Player_direction_changed')

func _on_Player_direction_changed(direction):
	rotation = direction.angle()
#	#problem with this is that it rotates weirdly if rotation and direction are different (negative vs positive)
#	tween.interpolate_property(self, "rotation", rotation, direction.angle(), 1, Tween.TRANS_LINEAR, Tween.EASE_IN)
#	tween.start()
