extends RayCast3D
@onready var prompt: Label = $Label

func _physics_process(delta: float) -> void:
	prompt.text = ""
	
	
	if is_colliding():
		var collider = get_collider()
		
		if Input.is_action_pressed("interact"):
			if collider is interactable:
				prompt.text = collider.message
