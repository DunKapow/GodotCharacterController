extends CharacterBody3D

# --- Player Nodes --- #
@onready var collider: CollisionShape3D = $MainCollider
@onready var headCheck: RayCast3D = $CameraPivot/HeadCheck

# --- Basic Movement --- #
@export_category("Movement")
# --- X and Z axis --- #
var currentSpeed : float = walkSpeed
@export var walkSpeed : float = 5.0
@export var sprintSpeed : float = 10.0
@export var crouchSpeed : float = 3.5
@export var friction : float = 10.0
var smoothSpeed : float = friction
# --- Y axis --- #
@export var gravity : float = 9.8
@export var jumpForce : float = 3.5

# --- Crouching --- #
var crouching : bool = false
@export var standHeight : float = 2.0
var crouchHeight : float = standHeight / 2
@export var crouchSmooth : float = 0.2

# --- Camera --- #
@export_category("Camera")
@onready var cameraPivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D
@export var sensitivity : Vector2 = Vector2(1.0,1.0)
@export var cameraClamp : float = 85.0
var cameraOffsetY : float = 0.5;

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	sensitivity *= 0.004

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cameraPivot.rotate_y(-event.screen_relative.x * sensitivity.x)
		camera.rotate_x(-event.screen_relative.y * sensitivity.y)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-cameraClamp), deg_to_rad(cameraClamp))

func crouchHandler():
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		crouching = !crouching
		if crouching:
			collider.shape.height = crouchHeight
			currentSpeed = crouchSpeed
			headCheck.enabled = true
		elif !headCheck.is_colliding():
			collider.shape.height = standHeight
			currentSpeed = walkSpeed
			headCheck.enabled = false
		else:
			crouching = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		smoothSpeed = friction / 5.0
	else:
		smoothSpeed = friction
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and !crouching and !headCheck.is_colliding():
		velocity.y = jumpForce
	
	if Input.is_action_pressed("sprint") and !crouching:
		currentSpeed = sprintSpeed
	elif !crouching:
		currentSpeed = walkSpeed
	
	crouchHandler()
	
	collider.shape.height = clamp(collider.shape.height, crouchHeight, standHeight)
	
	var input_dir := Input.get_vector("moveLeft", "moveRight", "moveForward", "moveBackward")
	var direction := (cameraPivot.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, currentSpeed * direction.x, smoothSpeed * delta)
		velocity.z = lerp(velocity.z, currentSpeed * direction.z, smoothSpeed * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, smoothSpeed * delta)
		velocity.z = lerp(velocity.z, 0.0, smoothSpeed * delta)

	move_and_slide()
