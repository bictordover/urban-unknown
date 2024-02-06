extends CharacterBody3D

# player nodes
@onready var head = $head
@onready var standingCollision = $standingCollision
@onready var crouchingCollision = $crouchingCollision
@onready var raycast3D = $RayCast3D

# variables
var currentSpeed = 5.0
var lerpSpeed = 10.0
var direction = Vector3.ZERO
var crouchingDepth = -0.5

# constants
const crouchSpeed = 2.0
const sprintingSpeed = 8.0
const walkingSpeed = 5.0
const jumpVelocity = 4.5
const mouseSens = 0.2

# gravity
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	crouchingCollision.disabled = true
	
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouseSens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouseSens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	# apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#movement states

	# jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity
	
	# crouch
	if Input.is_action_pressed("crouch"):
		currentSpeed = crouchSpeed
		
		head.position.y = lerp(head.position.y, 1.8 + crouchingDepth, delta * lerpSpeed)
		
		standingCollision.disabled = true
		crouchingCollision.disabled = false
	# standing
	elif !raycast3D.is_colliding():
		head.position.y = lerp(head.position.y, 1.8, delta * lerpSpeed)
		
		standingCollision.disabled = false
		crouchingCollision.disabled = true
		
		# sprint
		if Input.is_action_pressed("sprint"):
			currentSpeed = sprintingSpeed
			
		# walking
		else:
			currentSpeed = walkingSpeed

	# input directions
	var input_dir = Input.get_vector("left", "right", "forward", "backwards")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerpSpeed)
	
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()
