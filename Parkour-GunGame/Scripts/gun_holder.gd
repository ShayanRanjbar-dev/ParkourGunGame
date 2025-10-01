extends Node3D
@onready var quad_rocket: Node3D = $"quad_rocket"
@onready var ak_47: Node3D = $ak_47
@export var parent : CharacterBody3D

var gun_tilt_amount :float = 0.3
var mouse_motion : Vector2
var gun_sway_amount :float = 0.0035
var move_vel : float
var gun_bob_position  : Vector3
var gun_bob_amount : float = 0.0125
var  current_gun_bob_amount : float 
var direction : float
var bob_frequency : float = 0.01
var bob_freg : float

enum list{ak_47,quad_rocket}
var selected_gun = list.ak_47
var target_gun  : Node3D =  ak_47


func _ready() -> void:
	gun_bob_position = position
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	gun_selector()
	gun_motion(delta,direction)
	target()
func gun_motion(delta:float,direct:float) ->void:
	mouse_motion = lerp(mouse_motion,Vector2.ZERO,delta * 7.5)
	if parent.is_on_wall_only() and !parent.is_on_floor_only():
		rotation.z = lerp(rotation.z,direct * gun_tilt_amount,7.5* delta)
	else:
		rotation.z = lerp(rotation.z,-direct * gun_tilt_amount,7.5* delta)
	rotation.x = lerp(rotation.x,-mouse_motion.y * gun_sway_amount , 7.5 * delta)
	rotation.y = lerp(rotation.y,-mouse_motion.x * gun_sway_amount, 7.5 * delta)
	if move_vel> 0:
		bob_freg = Time.get_ticks_msec() * bob_frequency
		position.y = lerp(position.y , position.y +   sin(bob_freg ) * current_gun_bob_amount,5* delta)
		position.x = lerp(position.x , position.x +  sin(bob_freg  / 2) * current_gun_bob_amount,5 * delta)
	elif move_vel <=0 :
		position.y = lerp(position.y , gun_bob_position.y ,8* delta)
		position.x = lerp(position.x , gun_bob_position.x,8* delta)
	if parent.slide_time != 0.5:
		target_gun.rotation.x = lerp(target_gun.rotation.x,-deg_to_rad(15.0),delta * 7.5)
	if parent.slide_time == 0.5 and parent.sliding != true :
		target_gun.rotation.x = lerp(target_gun.rotation.x,0.0, delta * 7.5)
	if !parent.is_on_wall() and !parent.is_on_floor():
		target_gun.rotation.x = lerp(target_gun.rotation.x,deg_to_rad(30.0),delta * 7.5)
func gun_selector():
	match selected_gun:
		list.ak_47:
			for i in list:
				if list[i] != (selected_gun ):
					for j in get_children():
							if j is Node3D :
								if j.name == i:
									j.hide()
				else:
					for j in get_children():
							if j is Node3D :
								if j.name == i:
									j.show()
									target_gun = j
		list.quad_rocket:
			for i in list:
				if list[i] != (selected_gun):
					for j in get_children():
							if j is Node3D:
								if j.name == i:
									j.hide()
									
				else:
					for j in get_children():
							if j is Node3D :
								if j.name == i:
									j.show()
									target_gun = j
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
			if event.is_released():
				var number = int(event.as_text_keycode())
				if number !=0:
					selected_gun = number-1


func target()->void:
		target_gun.parent = parent
		if target_gun.info.auto_reload != true:
			if Input.is_action_pressed("shoot"):
				target_gun.fire_bullet()
			if Input.is_action_just_pressed("reload"):
					target_gun.reload()
		else:
			if Input.is_action_just_pressed("shoot"):
				target_gun.fire_bullet()
			if Input.is_action_just_pressed("reload") and parent.is_on_floor():
					target_gun.reload()
