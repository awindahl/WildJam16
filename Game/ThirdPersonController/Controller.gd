extends Spatial

const ACCELERATION = 1
const DECELERATION = 2
const MAXSLOPEANGLE = 75

export(NodePath) var PlayerPath  = "" #You must specify this in the inspector!
export(float) var MovementSpeed = 0
export(float) var MaxJump = 50
export(float) var MouseSensitivity = 1
export(float) var RotationLimit = 25
export(float) var MaxZoom = 0.5
export(float) var MinZoom = 1.5
export(float) var ZoomSpeed = 2
export(float) var WalkSpeed = 20
export(float) var SprintSpeed = 30

var Player
var Normal = Vector3()
var myModel
var Animations
var InnerGimbal
var CameraCast
var Direction = Vector3()
var Rotation = Vector2()
var gravity = -60
var Movement = Vector3()
var ZoomFactor = 1
var ActualZoom = 1
var Speed = Vector3()
var CurrentVerticalSpeed = Vector3()
var JumpAcceleration = 3
var IsAirborne = false
var Yaw = 0
var isMoving = false
var temp = false
var cameraDefault
var AttackTimer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Player = get_node(PlayerPath)
	InnerGimbal =  $InnerGimbal
	myModel = get_parent().get_node("Mesh")
	CameraCast = get_node("InnerGimbal/RayCast")
	cameraDefault = get_node("InnerGimbal/Camera")
	AttackTimer = get_parent().get_node("AttackTimer")
	Animations = myModel.get_node("AnimationPlayer")

#func _unhandled_input(event):
#
#	if event is InputEventMouseMotion:
#		Yaw = fmod(Yaw - event.relative.x * MouseSensitivity/10, 360)
#		rotation = Vector3(0, deg2rad(Yaw), 0)
#		Rotation = event.relative

func _physics_process(delta):
	
	var Up = Input.is_action_pressed("Forward")
	var Down = Input.is_action_pressed("Down")
	var Left = Input.is_action_pressed("Left")
	var Right = Input.is_action_pressed("Right")
	var Jump = Input.is_action_just_pressed("Jump")
	var Sprint = Input.is_action_pressed("Sprint")
	var Aim = $InnerGimbal/Camera.get_camera_transform().basis
	var FirstAction = Input.is_action_just_pressed("FirstAction")
	
	if CameraCast.is_colliding():
		InnerGimbal.get_node("Camera").global_transform.origin = CameraCast.get_collision_point()
	else:
		InnerGimbal.get_node("Camera").translation = Vector3(0,0.4, 4)
	
	if Up:
		Direction -= Aim[2]
	if Down:
		Direction += Aim[2]
	if Left:
		Direction -= Aim[0]
	if Right:
		Direction += Aim[0]
	
	if Player.is_on_floor():
		CurrentVerticalSpeed = Vector3()
		
		if Up or Down or Left or Right:
			isMoving = true
			MovementSpeed = WalkSpeed
			if Sprint:
				MovementSpeed = SprintSpeed
		else:
			Direction = Vector3()
			isMoving = false
	else:
		CurrentVerticalSpeed.y += gravity * delta * 0.3
		
	Direction = Direction.normalized()
	
	# Movement and Acceleration
	var hVel = Movement
	hVel.y = 0
	var Target = Direction * MovementSpeed
	var Acceleration
	if Direction.dot(hVel) >= 0:
		Acceleration = ACCELERATION
	else:
		Acceleration = DECELERATION
	
	hVel = hVel.linear_interpolate(Target, Acceleration * MovementSpeed * delta)
	Movement.x = hVel.x
	Movement.z = hVel.z
	
	var newMovement = Movement
	newMovement = newMovement.round()
	
	#Player Rotation
	if Player.is_on_floor():
		var angle = atan2(Movement.x, Movement.z)
		var playerRotation = Player.get_rotation()
		
		playerRotation.y = angle
		myModel.set_rotation(playerRotation)
		
	#Camera Rotation
#	InnerGimbal.rotate_x(deg2rad(Rotation.y) * delta * MouseSensitivity * 3)
#	InnerGimbal.rotation_degrees.x = clamp(InnerGimbal.rotation_degrees.x, -RotationLimit, RotationLimit)
	
	Rotation = Vector2()
	
	if newMovement.x == 0 and newMovement.z == 0 and Player.is_on_floor() and not temp and AttackTimer.is_stopped():
		temp = true
		Animations.play("Idle", 0.6)
	if (newMovement.x != 0 or newMovement.z != 0) and Player.is_on_floor() and not FirstAction and AttackTimer.is_stopped() and AttackTimer.is_stopped():
		temp = false
		
		if Direction.dot(hVel) >= 0:
			Animations.play("Running", 0.05)
		
	if Jump and Player.is_on_floor():
		temp = false
		Animations.stop()
		Animations.play("Jump", -1)
		get_parent().get_node("JumpTimer").start()
#
	if FirstAction and Player.is_on_floor() and AttackTimer.is_stopped():
		AttackTimer.start()
		#Animations.stop()
		Animations.play("ArmAction", 0.01)
		temp = false
	
	# Apply Movement
	Movement += CurrentVerticalSpeed
	
	if AttackTimer.is_stopped():
		Player.move_and_slide(Movement, Vector3(0,1,0), 0.05, 4, deg2rad(MAXSLOPEANGLE))

func _jump():
	var Jump = Input.is_action_just_pressed("Jump")
	
	if Player.is_on_floor() and Movement.y < 0:
			Movement.y = MaxJump

func _on_JumpTimer_timeout():
	_jump()