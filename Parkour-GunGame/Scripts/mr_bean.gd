extends CharacterBody3D
@onready var ak_47: Node3D = $"camera holder/eye/Camera3D/gun holder/ak_47"
@onready var character_sounds: AudioStreamPlayer3D = $"camera holder/eye/Camera3D/character sounds"
@onready var camera_holder: Node3D = %"camera holder"
@onready var camera_3d: Camera3D = %Camera3D
@onready var gun_holder: Node3D = %"gun holder"
@onready var gun_holder_positon: Marker3D = $"camera holder/eye/Camera3D/gun holder positon"
@onready var eye: Node3D = $"camera holder/eye"
@onready var crouching_collision: CollisionShape3D = $"crouching collision"
@onready var standing_collision: CollisionShape3D = $"standing collision"
@onready var player_animation: AnimationPlayer = $"camera holder/eye/Camera3D/player animation"
@onready var wall_detector: RayCast3D = $"wall detector"
@onready var wall_detector_2: RayCast3D = $"wall detector2"
@onready var label: Label = $Control/Label
@onready var grapple: RayCast3D = $"camera holder/eye/Camera3D/grapple"
@onready var crosshair: TextureRect = $Control/crosshair

#export variables
@export_range(0.01,0.2) var mouse_sense :float = 0.1
@export var speed :float = 5.0
@export var jump_velocity :float = 6
@export var acceleration : float = 3.5
@export var camera_tilt_amount : float = 5


#speed
var decceleration :float = acceleration * 2
var current_speed : float
var run_speed :float = speed * 2
var crouch_speed :float = speed / 2.5
var slide_speed : float = run_speed * 1.5
var gravity : float = -9.8


#inputs
var direction: Vector3 
var inputdir_x : int
var inputdir_y : int

#collision hieght
var standing_hieght : float
var crouching_hieght : float


#move and fall velocity
var move_vel : float
var fall_velocity : float

#headbob
var headbob_speed :float = 12.0
var headbob_current_speed :float = 0.0
var headbob_intensity :float = 0.13
var headbob_current_intensity :float = 0.0
var headbob_vector :Vector2 = Vector2.ZERO
var headbob_index :float = 0.0

#speed states
enum states{idle,walk,run,crouch}
var state := states.idle

var walking :bool
var running :bool
var crouching : bool
var sliding : bool
var slide_time = 0.5
var grappling : bool
var fullscr : bool = true
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_T):
		fullscr = !fullscr
		if fullscr :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			Input.mouse_mode =Input.MOUSE_MODE_CAPTURED
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED) 
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		

func _ready() -> void:
	standing_hieght = camera_holder.position.y
	crouching_hieght = standing_hieght / 2
	
func player_movement(delta:float)->void:
	gun_holder.direction = inputdir_x
	if (!is_on_wall() and is_on_floor()) and sliding != true and Vector2(inputdir_x,inputdir_y) != Vector2.ZERO:
		gun_holder.move_vel = velocity.length()
	else:
		gun_holder.move_vel = 0.0
	if is_on_wall_only():
		var wall_jump := global_transform.basis * Vector3(inputdir_x,0,0).normalized()
		velocity.y += (gravity / 1.25) * delta
		if Input.is_action_just_pressed("jump") and inputdir_x != 0 and (!wall_detector.is_colliding() and !wall_detector_2.is_colliding()) :
			velocity= lerp(velocity,(-wall_jump * speed) * 37.5,7.5 * delta)
			velocity.y += jump_velocity / 2.5
	if sliding != true:
		inputdir_x= Input.get_axis("left","right")
		inputdir_y = Input.get_axis("forward","backward")
	direction = (global_basis * Vector3(inputdir_x,0,inputdir_y)).normalized()
	camera_motion(delta,inputdir_x)
	if Vector2(inputdir_x,inputdir_y) == Vector2.ZERO:

		state = states.idle
	elif Vector2(inputdir_x,inputdir_y) != Vector2.ZERO:
		state = states.walk
	if Input.is_action_pressed("run") and direction != Vector3.ZERO:
		state = states.run
	if is_on_floor() :
		if Input.is_action_just_pressed("jump") and state != states.crouch:
			if !is_on_wall():
				velocity.y = jump_velocity
			if is_on_wall():
				velocity.y += jump_velocity / 1.5
		if Input.is_action_pressed("crouch") and sliding == false:
			state = states.crouch
		if Input.is_action_just_pressed("slide") and (state == states.run ) :
			sliding = true
	if !is_on_floor() and !is_on_wall():
		velocity.y += gravity * 2 * delta
		fall_velocity = velocity.y
	match state:
		states.idle:
			character_sounds.stop()
			current_speed = 0
		states.walk:
			gun_holder.bob_frequency = 0.01
			gun_holder.current_gun_bob_amount = gun_holder.gun_bob_amount 
			current_speed = speed
			headbob_current_intensity =  headbob_intensity * 1.5
			headbob_current_speed = headbob_speed * 1.2
		states.run:
			gun_holder.bob_frequency = 0.01 * 2
			gun_holder.current_gun_bob_amount = gun_holder.gun_bob_amount * 1.25
			current_speed = run_speed
			headbob_current_intensity =  headbob_intensity * 2
			headbob_current_speed = headbob_speed * 1.75
		states.crouch:
			character_sounds.stop()
			gun_holder.bob_frequency = 0.01 / 1.5
			gun_holder.current_gun_bob_amount  = gun_holder.gun_bob_amount
			current_speed = crouch_speed
			headbob_current_intensity =  headbob_intensity / 1.25
			headbob_current_speed = headbob_speed  / 1.25
	if state == states.crouch:
		camera_holder.position.y = lerp(camera_holder.position.y,crouching_hieght,delta * 7.5)
		standing_collision.disabled = true
		crouching_collision.disabled = false
	else: 
		standing_collision.disabled = false
		crouching_collision.disabled = true
		camera_holder.position.y = lerp(camera_holder.position.y,standing_hieght,delta * 7.5)
	if sliding == true:
		current_speed = slide_speed
		camera_3d.rotation.z = lerp(camera_3d.rotation.z,-inputdir_x*deg_to_rad(30.0),delta * 7.5)
		camera_holder.position.y = lerp(camera_holder.position.y,0.0,delta * 7.5)
		standing_collision.disabled = true
		crouching_collision.disabled = false
		velocity = lerp(velocity ,global_basis * Vector3(inputdir_x,0,inputdir_y).normalized() * (slide_speed / 2 ),7.5 * delta)
		slide_time -= delta
	if slide_time <= 0 or( !is_on_floor() or Input.is_action_just_pressed("jump")):
		sliding = false
		standing_collision.disabled = false
		crouching_collision.disabled = true
		camera_3d.rotation.z = lerp(camera_3d.rotation.z,0.0,delta * 7.5)
		camera_holder.position.y = lerp(camera_holder.position.y,standing_hieght,delta * 7.5)
		slide_time = 0.5
	
	if fall_velocity < -15 and is_on_floor():
		fall_velocity = 0.0
		if inputdir_x == 0 and inputdir_y !=0:
			if inputdir_y == -1:
				player_animation.play("simple_fall")
			else:
				player_animation.play_backwards("simple_fall")
			sliding = true
	if direction:
		headbob_index += headbob_current_speed *  delta
		velocity.x = lerp(velocity.x , direction.x * current_speed,acceleration * delta)
		velocity.z = lerp(velocity.z , direction.z * current_speed,acceleration * delta)
	else:
		headbob_index = 0.0
		velocity.x = lerp(velocity.x , 0.0,decceleration * delta)
		velocity.z = lerp(velocity.z , 0.0,decceleration * delta)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode ==Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-mouse_sense * event.relative.x))
		camera_holder.rotation.x = clamp(camera_holder.rotation.x,-PI/2,PI/2)
		camera_holder.rotate_x(deg_to_rad(-mouse_sense * event.relative.y))
		gun_holder.mouse_motion = event.relative





func camera_motion(delta:float ,dir:int)->void:
	if is_on_floor() and !is_on_wall():
		camera_3d.rotation.z = lerp(camera_3d.rotation.z,deg_to_rad(-dir * camera_tilt_amount),7.5 * delta)
	if is_on_wall_only():
		camera_3d.rotation.z = lerp(camera_3d.rotation.z,deg_to_rad(dir * 5 *camera_tilt_amount),7.5 * delta)
	else:
		camera_3d.rotation.z = lerp(camera_3d.rotation.z,deg_to_rad(0),7.5 * delta)
	if move_vel > 0 and is_on_floor():
		headbob_vector.y = sin(headbob_index)
		headbob_vector.x = sin(headbob_index/2)
		eye.position.y = lerp(eye.position.y , headbob_vector.y*((headbob_current_intensity / 2.0) + 0.05),delta * 7.5)
		eye.position.x = lerp(eye.position.x , headbob_vector.x*(headbob_current_intensity ),delta * 7.5)
	if move_vel <= 0:
		eye.position.y = lerp(eye.position.y , 0.0,delta * 7.5)
		eye.position.x = lerp(eye.position.x , 0.0,delta * 7.5)
	#if fall_velocity < 0 and is_on_floor():
		#fall_velocity = 0
		#player_animation.play("simple_fall")
	if is_on_floor() and sliding != true:
			move_vel = velocity.length()
	else:
			move_vel = 0.0



func _physics_process(delta: float) -> void:
	label.text = "FPS: "+ str(Engine.get_frames_per_second())
	if Input.is_action_pressed("slow mo"):
		Engine.time_scale = 0.25
	if Input.is_action_just_released("slow mo"):
		Engine.time_scale = 1
	player_movement(delta)
	#gun_setting()
	move_and_slide()
	
