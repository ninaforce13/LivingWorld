const MIN_LENGTH = 3
const MAX_LENGTH = 7
const LETTERS = {
  'VOWEL': ['a', 'e', 'a', 'e', 'i', 'o', 'o', 'a', 'e', 'a', 'e', 'i', 'a', 'e', 'a', 'e', 'i', 'o', 'o', 'a', 'e', 'a', 'e', 'i', 'y'],
  'DOUBLE_VOWEL': ['oi', 'ai', 'ou', 'ei', 'ae', 'eu', 'ie', 'ea'],

  'CONSONANT': ['b', 'c', 'c', 'd', 'f', 'g', 'h', 'j', 'l', 'm', 'n', 'n', 'p', 'r', 'r', 's', 't', 's', 't', 'b', 'c', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'n', 'p', 'r', 'r', 's', 't', 's', 't', 'v', 'w', 'x', 'z'],
  'DOUBLE_CONSONANT': ['mm', 'nn', 'st', 'ch', 'll', 'tt', 'ss'],

  'COMPOSE': ['qu', 'gu', 'cc', 'sc', 'tr', 'fr', 'pr', 'br', 'cr', 'ch', 'll', 'tt', 'ss', 'gn']
}

const TRANSITION = {
  'INITIAL': ['VOWEL', 'CONSONANT', 'COMPOSE'],
  'VOWEL': ['CONSONANT', 'DOUBLE_CONSONANT', 'COMPOSE'],
  'DOUBLE_VOWEL': ['CONSONANT', 'DOUBLE_CONSONANT', 'COMPOSE'],

  'CONSONANT': ['VOWEL', 'DOUBLE_VOWEL'],
  'DOUBLE_CONSONANT': ['VOWEL', 'DOUBLE_VOWEL'],

  'COMPOSE': ['VOWEL']
}

static func pick_random_number(max_value, min_value=0):
	var random = Random.new()
	return round(random.rand_int(max_value) % (max_value - min_value) + min_value)

static func clone_array(original):
	var result = []

	for item in original:
		result.append(item)

	return result

static func get_letter(state, last_letter, max_length):
	var transitions = clone_array(TRANSITION[state])

	if max_length < 3:
		transitions.erase('COMPOSE')
		transitions.erase('DOUBLE_CONSONANT')
		transitions.erase('DOUBLE_VOWEL')

	var state_index = pick_random_number(transitions.size())

	state = transitions[state_index]

	var letters_list = LETTERS[state]
	var letter_index = pick_random_number(letters_list.size())

	return [state, letters_list[letter_index]]

static func generate(min_length=MIN_LENGTH, max_length=MAX_LENGTH):
	var length = pick_random_number(max_length, min_length)
	var name = ''
	var last_letter = ''
	var index = 0
	var state = 'INITIAL'

	while index < length:
		var obj = get_letter(state, last_letter, length - index)

		state = obj[0]
		last_letter = obj[1]

		name += last_letter
		index += last_letter.length()

	return name.capitalize()
