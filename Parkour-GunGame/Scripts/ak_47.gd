extends Node3D
@onready var bullet_spawner: Marker3D = $"bullet spawner"
@onready var gun_animation: AnimationPlayer = $gun_animation

const BULLET_RIFLE = preload("res://Scenes/bullet_rifle.tscn")

@export var info : gun_info


var parent : CharacterBody3D
func fire_bullet()->void:
	if info.ammo > 0 :
		if !gun_animation.is_playing():
			gun_animation.play("shooting")
			var bullet = BULLET_RIFLE.instantiate()
			parent.get_parent().add_child(bullet)
			bullet.global_position = bullet_spawner.global_position
			bullet.global_basis = bullet_spawner.global_basis
			info.ammo -= 1
			
func reload()->void:
	if info.ammo < 30:
		gun_animation.play("reloading")
		await  gun_animation.animation_finished
		info.ammo = 30
