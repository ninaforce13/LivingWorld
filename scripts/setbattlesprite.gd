extends Control

export (NodePath) var charconfig
onready var monsterspritecontainer = $MarginContainer/MonsterSpriteContainer1/
onready var spritecontainer = $MarginContainer/MonsterSpriteContainer1/Viewport/BattleSlot/SpriteContainer
onready var anim = $MarginContainer/MonsterSpriteContainer1/Viewport/BattleSlot/AnimationPlayer
var characterconfig
var jsonparser = preload("res://mods/LivingWorld/scripts/RangerDataParser.gd")
func _ready():
	if get_parent().has_node("EncounterConfig/CharacterConfig"):
		characterconfig = get_parent().get_node("EncounterConfig/CharacterConfig")
		var character = characterconfig._create_character(Random.new(), 0)
		monsterspritecontainer.sprite = character.battle_sprite_instance()

func set_sprite(json_data):
	characterconfig = CharacterConfig.new()
	characterconfig.character_kind = Character.CharacterKind.HUMAN
	jsonparser.set_char_config(characterconfig, json_data)
	var character = characterconfig._create_character(Random.new(), 0)
	monsterspritecontainer.sprite = character.battle_sprite_instance()

func animate_turn():
	spritecontainer.idle = "idle"

func animate_turn_end():
	spritecontainer.idle = "inactive"

func animate_damage():
	anim.play("hurt")

func animate_defeat():
	pass

