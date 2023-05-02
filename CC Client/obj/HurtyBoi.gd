extends Area2D

var hurties = []

func _ready():
	pass

func _process(delta):
	pass

func _on_HurtyBoi_body_entered(body):
	if body.has_node("Health"):
		hurties.append(body)

func _on_HurtyBoi_body_exited(body):
	hurties.erase(body)
