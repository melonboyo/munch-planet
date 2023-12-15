extends Control


signal grabbed(hand: Constants.SnakeHand)
signal win
signal failed

const SNAKE_GRAVITY := 80.0
const SPAWN_VELOCITY := 4.0
const SNAKE_SLIP_VELOCITY := -80.0
const SNAKE_SPAWN_Y := -200
const SNAKE_DEATH_Y := 1050
const SNAKE_SPAWN_OFFSET_X := 100

var enabled := false

var can_catch = false
var snake_hand: Constants.SnakeHand
@onready var snake_hands := {
	Constants.SnakeHand.Left: %SnakeHandLeft,
	Constants.SnakeHand.Middle: %SnakeHandMiddle,
	Constants.SnakeHand.Right: %SnakeHandRight,
}
@onready var snake := $SnakeFalling as AnimatedSprite2D
var snake_velocity := 0.0


func enable():
	await get_tree().create_timer(1).timeout
	snake.visible = true
	enabled = true
	set_new_snake_hand(get_random_hand())
	

func disable():
	enabled = false
	snake.visible = false


func get_random_hand():
	return Constants.SnakeHand.values()[randi() % Constants.SnakeHand.size()]


func set_new_snake_hand(hand: Constants.SnakeHand):
	snake_hand = hand
	can_catch = true
	snake_velocity = SPAWN_VELOCITY
	snake.global_position = Vector2(
		snake_hands[snake_hand].global_position.x + SNAKE_SPAWN_OFFSET_X, 
		SNAKE_SPAWN_Y
	)


func _process(delta: float):
	if not enabled:
		return
	
	snake_velocity += SNAKE_GRAVITY * delta
	snake.global_position.y += snake_velocity
	
	if snake.global_position.y > SNAKE_DEATH_Y:
		failed.emit()


func _on_grab(hand: Constants.SnakeHand):
	if not can_catch:
		return
		
	# you SUCK
	if hand != snake_hand:
		failed.emit()
		return
	
	grabbed.emit(hand)
	can_catch = false
	
	var current_hand = snake_hands[hand]
	if current_hand.is_grabbing_snake(snake):
		# SUCCESS you did it!! you grabbed the snake!!
		current_hand.has_snake = true
		win.emit()
		return
	
	# Not grabbed, SHOOT THAT GUY UP IN THE SKY
	snake_velocity = SNAKE_SLIP_VELOCITY
	await get_tree().create_timer(0.7).timeout
	set_new_snake_hand(get_random_hand())


func _on_snake_hand_left_button_down():
	_on_grab(Constants.SnakeHand.Left)


func _on_snake_hand_middle_button_down():
	_on_grab(Constants.SnakeHand.Middle)


func _on_snake_hand_right_button_down():
	_on_grab(Constants.SnakeHand.Right)
