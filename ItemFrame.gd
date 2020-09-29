extends Sprite

onready var particles = [$BR, $BL, $TL, $TR]

var sprites = []
var item_list = []

var item_sprites = {
	enums.ITEMS.BOO: load("res://items/boo.png"),
	enums.ITEMS.MUSHROOM: load("res://items/mushroom.png"),
	enums.ITEMS.STAR: load("res://items/star.png"),
	enums.ITEMS.COIN: load("res://items/coin.png")
}

var timer = -1
var selected = null
var dissolve_timer = -1
var begin_timer = 0
func start(items):
	if timer != -1 or selected != null:
		return
	timer = 160 + randi() % 25
	selected = null
	dissolve_timer = -1
	begin_timer = 50
	item_list = items
	$Panel.modulate.v = .5
	sprites = []
	for child in $Panel.get_children():
		child.queue_free()
	var i = 0
	var shuffled_list = item_list
	shuffled_list.shuffle()
	for item in shuffled_list:
		var sprite = Sprite.new()
		sprite.texture = item_sprites[item]
		sprite.position.y = 7 - 17 * i
		sprite.position.x = 10
		sprite.modulate.a = 0
		sprite.material = ShaderMaterial.new()
		sprite.material.set_shader(load("dissolve.shader"))
		sprite.material.set_shader_param("noiseTexture", load("res://noise.png")) 
		sprites.append({"sprite": sprite, "item": item})
		$Panel.add_child(sprite)
		i += 1

func use_item():
	if selected != null and dissolve_timer == -1:
		dissolve_timer = 0
		$Flash.modulate.a = 1
		return sprites[selected]["item"]

func _process(_delta):
	if selected != null:
		$Panel.modulate.v += (1 - $Panel.modulate.v) * .1
		$Flash.modulate.a -= $Flash.modulate.a * .2
		if dissolve_timer != -1 and selected != null:
			dissolve_timer += .03
			sprites[selected]["sprite"].material.set_shader_param("dissolveAmount", dissolve_timer)
			if dissolve_timer > 1.1:
				selected = null
	elif timer != -1:
		if begin_timer > 0:
			begin_timer -= 1
		else:
			timer = max(10, timer - 1)
			if timer < 30:
				timer += .5
			var i = 0
			for sprite in sprites:
				sprite["sprite"].modulate.a += (1 - sprite["sprite"].modulate.a) * .1
				sprite["sprite"].position.y += _delta * timer
				if sprite["sprite"].position.y > 24:
					sprite["sprite"].position.y -= 17 * item_list.size()
					if timer < 15:
						selected = (i + 1) % item_list.size()
						timer = -1
						for particle in particles:
							particle.play()
				i += 1
