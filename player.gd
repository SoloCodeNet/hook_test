extends KinematicBody2D
onready var scene    = get_parent()
onready var visor = get_parent().get_node("visor")
onready var ray_hook = $rotate_helper/ray_hook
onready var ray_blok = $rotate_helper/ray_blok
onready var laser    = $rotate_helper/laser

signal hooked(value)

var dirx:float=0.0
var vel:Vector2=Vector2.ZERO
var target:Vector2=Vector2.ZERO
var normed:Vector2=Vector2.ZERO
var speed:float=200.0
var jump:bool=false
var hook:bool=false
var touch:bool = false
var locked:bool = false
var blocked:bool = false
var mouse: Vector2
const GRAVITY = 15

export(float) var hooked_speed=500.0

func _ready() -> void:
	var err = self.connect("hooked", get_parent(), "hooked")
	var lst:PoolVector2Array=[]
	lst.append(Vector2.ZERO)
	lst.append(ray_hook.cast_to)
	laser.points = lst
	print(err)
	
func _physics_process(delta: float) -> void:
	mouse = get_global_mouse_position()
	input_loop()
	hook_loop()
	movement_loop()
	anim_loop()

func movement_loop():
	normed = (target - global_position).normalized()
	$rotate_helper.look_at(mouse)
	vel.y += GRAVITY
	vel.x = lerp(vel.x, speed * dirx, 0.1)
	if jump: 
		if is_on_floor() or is_on_wall(): 
			vel.y = -250
			
	if locked:
		var move_hook = normed * hooked_speed
		vel = move_and_slide(move_hook, Vector2.UP)
	else:
		vel = move_and_slide(vel, Vector2.UP)
		
func anim_loop():
	if self.global_position < mouse: $spr_body.flip_h= false
	if self.global_position > mouse: $spr_body.flip_h= true

func hook_loop():
	blocked = ray_blok.is_colliding()
	if !locked:
		if ray_hook.is_colliding():
			var p = scene.light_tile(ray_hook.get_collision_point() + normed * 5)
			target = ray_hook.get_collision_point()
			visor.global_position = target
			visor.frame = 2
			touch = true
		else:
			scene.reset()
			visor.frame = 3
			touch  = false
		
	if hook  and touch and !locked:
		visor.global_position = ray_hook.get_collision_point()
		locked=true
		$AnimationPlayer.play("colli_on")
		emit_signal("hooked", true)
		
func input_loop()->void:
	dirx = Input.get_action_strength("right") - Input.get_action_strength("left")
	jump = Input.is_action_just_pressed("jump")
	if !blocked:
		hook = Input.is_action_just_pressed("hook")


func _on_Area2D_body_entered(body: PhysicsBody2D) -> void:
	if locked:
		locked = false
		emit_signal("hooked", false)
		$AnimationPlayer.play("colli_off")
#		call_deferred("disabled",$rotate_helper/Area2D/CollisionShape2D, true)