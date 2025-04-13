extends Control

func _ready() -> void:
	%PauseMenuButtons.visible = false
	$AnimationPlayer.play("RESET")

func _process(_delta) -> void:
	testEsc()


func resume():
	$CanvasLayer.layer = 1
	get_tree().paused = false
	%PauseMenuButtons.visible = false
	$AnimationPlayer.play_backwards("blur")


func pause():
	$CanvasLayer.layer = 52  # layer should be highest
	get_tree().paused = true
	%PauseMenuButtons.visible = true
	$AnimationPlayer.play("blur")

	
func testEsc():
	if Input.is_action_just_pressed("Pause"):
		if get_tree().paused == false:
			pause()
		else:
			resume()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	resume()
