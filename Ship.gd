extends RigidBody2D

export var thruster_magnitude = 100
export var rthruster_magnitude = 1000
var screen_size

var thrust = Vector2(0, -thruster_magnitude)

func _ready():
	screen_size = get_viewport_rect().size
	friction = 0

func _integrate_forces(state):
	if forwardInputOnly():
		applied_force = thrust.rotated(rotation)
		calculate_animation("forward")
	elif Input.is_action_pressed("ui_up") && Input.is_action_pressed("ui_modify"):
		applied_force = thrust.rotated(rotation) * 2
		calculate_animation("forward")
	else:
		applied_force = Vector2()
		
	var rotation_direction = 0
	if Input.is_action_pressed("ui_right") && Input.is_action_pressed("ui_modify"):
		add_force(Vector2.ZERO, thrust.rotated(rotation + PI/2))
		calculate_animation("strafe")
		$AnimatedSprite.flip_h = true
	elif Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_modify"):
		add_force(Vector2.ZERO, thrust.rotated(rotation - PI/2))
		calculate_animation("strafe")
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_modify"):
		rotation_direction += 1
		calculate_animation("rotate")
		$AnimatedSprite.flip_h = true
	elif Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_modify"):
		rotation_direction -= 1
		calculate_animation("rotate")
		$AnimatedSprite.flip_h = false
	applied_torque = rotation_direction * rthruster_magnitude
	
	if modifyInputOnlyPressed():
		apply_thruster_damping()
	if applied_force.length() <= 0 && applied_torque == 0:
		$AnimatedSprite.animation = "idle"
		$AnimatedSprite.stop()
	else:
		$AnimatedSprite.play()

# Sets 'start' or regular animation of the given animation by the string `name`
# by checking if the Start animation is finished playing. This allows the game to
# play the start animation directly after it the regular animation. Used this to
# run the thruster starts and continous animations.
func calculate_animation(name):
	var startName = name + "Start"
	if $AnimatedSprite.animation == startName && $AnimatedSprite.frame == $AnimatedSprite.frames.get_frame_count(startName)-1:
		$AnimatedSprite.animation = name
	elif (!$AnimatedSprite.is_playing() || $AnimatedSprite.animation != startName) && $AnimatedSprite.animation != name:
		$AnimatedSprite.animation = startName

func forwardInputOnly():
	return Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left") && !Input.is_action_pressed("ui_modify")

func modifyInputOnlyPressed():
	return Input.is_action_pressed("ui_modify") && !Input.is_action_pressed("ui_up") && !Input.is_action_pressed("ui_right") && !Input.is_action_pressed("ui_left")

func opposite_torque():
	return angular_velocity * -1 * rthruster_magnitude

func opposite_force():
	return linear_velocity * -1 * thruster_magnitude
	
func apply_thruster_damping():
	if angular_velocity >= 0:
		applied_torque = opposite_torque()
	elif linear_velocity.length() != 0:
		applied_force = opposite_force()
		