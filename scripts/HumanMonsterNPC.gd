tool
extends NPC
enum FORMS {HUMAN, MONSTER}
signal character_changed

const UniqueSprite3D = preload("res://nodes/layered_sprite/UniqueSprite3D.gd")
const LayeredSprite3D = preload("res://nodes/layered_sprite/LayeredSprite3D.gd")
const WorldUniqueSprite3DScene = preload("res://nodes/layered_sprite/WorldUniqueSprite3D.tscn")
const WorldHumanSprite3DScene = preload("res://nodes/layered_sprite/WorldHumanSprite3D.tscn")

export (Dictionary) var sprite_colors:Dictionary setget set_sprite_colors
export (Dictionary) var sprite_part_names:Dictionary setget set_sprite_part_names
export (PackedScene) var sprite_body:PackedScene setget set_sprite_body
export (Resource) var character:Resource setget set_character
export (bool) var use_monster_form = false
export (bool) var supress_abilities = false
var previous_monster_form_index = 0
var monster_index:Array = []
var sfx:CharacterSfx
func _ready():
	if character != null:
		set_character(character)
	else :
		refresh_sprite()

func set_transform_index():
	monster_index = []
	var monster_forms = get_node("MonsterForms")
	for i in range (0,monster_forms.get_child_count()):
		monster_index.push_back(i)
	var random = Random.new()
	random.shuffle(monster_index)
func player_transform(value=-1):
	if value == -1:
		value = 0 if use_monster_form else 1
	var cutscene = get_node("Transform")
	if cutscene:
		cutscene.set_bb("mode",value)
		cutscene.run()
func swap_sprite(value:int, forced_index:int = -1):
	var random = Random.new()
	var npc_manager = preload("res://mods/LivingWorld/scripts/NPCManager.gd")
	use_monster_form = value == FORMS.MONSTER
	var dominant_sprite
	var monster_forms = get_node("MonsterForms")
	if monster_index.empty():
		set_transform_index()
	var index = monster_index.pop_front() if forced_index == -1 else forced_index
	var selection = monster_forms.get_child(index)
	var monster_sprite = selection.get_child(0)
	var human_sprite = get_node("Sprite")
	monster_sprite.visible = use_monster_form
	human_sprite.visible = !use_monster_form
	if use_monster_form:
		if sprite:
			monster_sprite.set_static_amount(sprite.static_amount)
			monster_sprite.set_static_speed(sprite.static_speed)
			monster_sprite.set_wave_amplitude(sprite.wave_amplitude)
			monster_sprite.set_wave_v_frequency(sprite.wave_v_frequency)
			monster_sprite.direction = sprite.direction
		dominant_sprite = monster_sprite
		human_sprite.visible = false
		npc_manager.set_transformation_index(index)
	else:
		if sprite:
			human_sprite.set_static_amount(sprite.static_amount)
			human_sprite.set_static_speed(sprite.static_speed)
			human_sprite.set_wave_amplitude(sprite.wave_amplitude)
			human_sprite.set_wave_v_frequency(sprite.wave_v_frequency)
			human_sprite.direction = sprite.direction
		dominant_sprite = human_sprite
		monster_sprite.visible = false
		npc_manager.set_transformation_index(-1)
	sprite = dominant_sprite
	state_machine.set_formname(selection.name)
	state_machine.change_forms(use_monster_form)
	sprite.visible = true
	if previous_monster_form_index != index:
		monster_forms.get_child(previous_monster_form_index).get_child(0).visible = false
		previous_monster_form_index = index

func refresh_sprite():
	if not sprite or use_monster_form:
		return

	if sprite_body:
		if not (sprite.scene is UniqueSprite3D):
			sprite.set_scene(WorldUniqueSprite3DScene)
		sprite.scene.sprite_body = sprite_body
	else :
		if sprite.scene is UniqueSprite3D:
			sprite.set_scene(WorldHumanSprite3DScene)

	sprite.scene.part_names = sprite_part_names.duplicate()
	sprite.scene.colors = sprite_colors.duplicate()

	sprite.scene.refresh()

	if Engine.editor_hint:
		property_list_changed_notify()

func set_sprite_colors(value:Dictionary):
	sprite_colors = value
	refresh_sprite()

func set_sprite_part_names(value:Dictionary):
	sprite_part_names = value
	refresh_sprite()

func set_sprite_body(value:PackedScene):
	sprite_body = value
	refresh_sprite()

func set_character(value:Character):
	if character:
		character.disconnect("appearance_changed", self, "_update_appearance")
		if character.partner_id != "":
			remove_from_group(character.partner_id)
			remove_from_group("has_partner_id")
	character = value
	if character:
		npc_name = character.name
		pronouns = character.pronouns
		sfx = character.sfx
		character.connect("appearance_changed", self, "_update_appearance")
		if character.partner_id != "":
			add_to_group(character.partner_id)
			add_to_group("has_partner_id")
	_update_appearance()
	emit_signal("character_changed")

func _update_appearance():
	if character and not use_monster_form:
		sprite_body = character.world_sprite
		sprite_colors = character.human_colors.duplicate()
		sprite_part_names = character.human_part_names.duplicate()
		sfx = character.sfx
	refresh_sprite()

func randomize_sprite(rand:Random = null):
	if rand == null:
		rand = Random.new()
	var template = HumanLayersHelper.randomize_sprite(rand, sprite_part_names, sprite_colors)
	pronouns = template.pronouns
	sfx = rand.choice(template.sfx)
	refresh_sprite()
	return template

func _get_property_list():
	var properties = []
	HumanLayersHelper.add_world_human_properties(properties)
	return properties

func _set(property:String, value)->bool:
	if HumanLayersHelper.set_human_property(property, value, sprite_part_names, sprite_colors):
		refresh_sprite()
		return true
	return false

func _get(property:String):
	return HumanLayersHelper.get_human_property(property, sprite_part_names, sprite_colors)

func get_aabb()->AABB:
	return Spatials.get_collision_aabb(self)


