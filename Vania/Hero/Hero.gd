extends CharacterBody2D


const SPEED = 350
const JUMP_VELOCITY = -400.0
const SLIDE_TIME = 0.95
const SLIDE_COOLDOWN = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var slide_timer = 0.0
var slide_cooldown_timer = 0.0

@onready var animation = get_node("AnimationPlayer")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		animation.play("Jump")
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction == -1:
			get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
			get_node("AnimatedSprite2D").flip_h = false
			
	#Should handle the crouch and slide animation
	var crouch = Input.is_action_pressed("ui_down")
	if crouch and velocity.y == 0 and slide_cooldown_timer <= 0.0:
		if direction and is_on_floor():
			velocity.x = direction *  SPEED
			slide_timer += delta
			if slide_timer <= SLIDE_TIME:
				animation.play("Slide")
			else:
				animation.play("Idle")
				slide_timer = 0.0
				#Start slide cooldown
				slide_cooldown_timer = SLIDE_COOLDOWN
		else:
			animation.play("Crouch")
			slide_timer = 0.0
	else:
		if direction:
			velocity.x = direction * SPEED
			if velocity.y == 0:
				animation.play("Run")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if velocity.y == 0 and not crouch:
				animation.play("Idle")
				slide_timer = 0.0
				
	if slide_cooldown_timer > 0.0:
		slide_cooldown_timer -= delta

	move_and_slide()
