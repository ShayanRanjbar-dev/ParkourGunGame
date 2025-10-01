extends Node3D
@onready var board_2: Node3D = $board2

func _ready() -> void:
	var tween = self.create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self,"position:y",position.y -0.25,1.5)
	tween.tween_property(self,"position:y",position.y +0.25,1.5)

func _process(delta: float) -> void:
	board_2.rotation.y -= delta
	board_2.rotation.x -= delta
func _on_player_detector_body_entered(body: Node3D) -> void:
	get_tree().call_deferred("reload_current_scene")
