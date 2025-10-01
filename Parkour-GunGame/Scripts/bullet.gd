extends Node3D
@onready var cpu_particles_3d: CPUParticles3D = $CPUParticles3D
@onready var bullet_1: MeshInstance3D = $bullet1
@onready var ray_group: Node3D = $ray_group
@onready var bullet_sound: AudioStreamPlayer3D = $"bullet sound"

var speed := 27.5
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	bullet_sound.pitch_scale  = randf_range(0.90,1.10)
func _process(delta: float) -> void:
	position +=  transform.basis * Vector3(0,0,-speed) * delta
	for i in ray_group.get_children():
		if i is RayCast3D:
			if i.is_colliding():
				var c = i.get_collider()
				if c is CSGBox3D:
					bullet_1.hide()
					cpu_particles_3d.position = (i.position )
					cpu_particles_3d.top_level = true
					cpu_particles_3d.emitting = true
					i.enabled = false
			else:
				await get_tree().create_timer(10.0).timeout
				queue_free()
func _on_cpu_particles_3d_finished() -> void:
	queue_free()
