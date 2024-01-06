extends Control

export (NodePath) var charconfig
onready var spritecontainer = $MarginContainer/MonsterSpriteContainer1/
var characterconfig

func _ready():
	if get_parent().has_node("EncounterConfig/CharacterConfig"):
		characterconfig = get_parent().get_node("EncounterConfig/CharacterConfig")
		var character = characterconfig._create_character(Random.new(), 0)
		spritecontainer.sprite = character.battle_sprite_instance()

