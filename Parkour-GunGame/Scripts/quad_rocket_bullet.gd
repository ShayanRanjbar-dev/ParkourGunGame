extends Node3D
#@onready var ray_cast_3d: RayCast3D = $RayCast3D
#@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D

var speed := 30
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position +=  transform.basis * Vector3(0,0,-speed) * delta
	#if ray_cast_3d.is_colliding():
		#var c = ray_cast_3d.get_collider()
		#cpu_particles_3d.emitting = true
		#queue_free()
	#else:
	await get_tree().create_timer(10.0).timeout
	queue_free()
