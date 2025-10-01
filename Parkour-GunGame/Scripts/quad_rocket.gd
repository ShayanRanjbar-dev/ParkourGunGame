extends Node3D
@onready var gun_animation: AnimationPlayer = $gun_animation
@onready var bullet_spawner: Marker3D = $quadrocket2/bullet_spawner

const QUAD_ROCKET_BULLET = preload("res://Scenes/quad_rocket_bullet.tscn")
@export var info : gun_info
var ammo = 2

var parent : CharacterBody3D
# Called when the node enters the scene tree for the first time.
func fire_bullet()->void:
	if info.ammo > 0 and  !gun_animation.is_playing():
		gun_animation.play("shooting")
		var bullet = QUAD_ROCKET_BULLET.instantiate()
		parent.get_parent().add_child(bullet)
		bullet.global_position = bullet_spawner.global_position
		bullet.global_basis = bullet_spawner.global_basis
		info.ammo -= 1
		var v = (parent.camera_holder.global_transform.basis *  Vector3(0,0,1) .normalized() )* 90
		parent.velocity = v 
		parent.velocity.y /= 4
		await  gun_animation.animation_finished
		reload()
func reload()->void:
	if info.ammo < 2:
		if !parent.is_on_floor():
			gun_animation.play("reloading")
		else:
			gun_animation.play("reloading")
			await  gun_animation.animation_finished
			info.ammo = 2
