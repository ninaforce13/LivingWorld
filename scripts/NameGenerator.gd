const NAMES = [
	"James", "Emily", "John", "Olivia", "Robert", "Sophia", "Michael", "Ava", "William", "Isabella",
	"David", "Mia", "Richard", "Charlotte", "Joseph", "Amelia", "Charles", "Harper", "Thomas", "Evelyn",
	"Christopher", "Abigail", "Daniel", "Ella", "Matthew", "Scarlett", "Anthony", "Grace", "Donald", "Chloe",
	"Mark", "Victoria", "Paul", "Madison", "Steven", "Luna", "Andrew", "Lily", "Kenneth", "Brooklyn",
	"Joshua", "Zoe", "George", "Natalie", "Kevin", "Penelope", "Brian", "Riley", "Edward", "Leah",
	"Ron", "Hazel", "Jerry", "Violet", "Greg", "Aurora", "Derek", "Savannah", "Sam", "Audrey",
	"Peter", "Skye", "Kyle", "Ivy", "Ian", "Paisley", "Roger", "Serenity", "Alan", "Willow",
	"Keith", "Quinn", "Jeremy", "Piper", "Terry", "Ruby", "Lawrence", "Nova", "Sean", "Jade",
	"Christian", "Alexis", "Ethan", "Brielle", "Austin", "Maddison", "Jesse", "Aria", "Joe", "Ellie",
	"Tyler", "Ariana", "Aaron", "Layla", "Harry", "Zoe", "Luke", "Bella", "Adam", "Emma", "Matt", "Andrea","Abby",
	"Anna", "Jose", "Maria", "Luz", "Nina", "Jojo", "Amadeus", "Patel", "Scott", "Coraline", "Natalia", "Zamara",
	"Dash", "Potor", "Guy", "Denji", "Ken", "Estrella", "Carlos", "Ashish", "Barley", "Sasha", "Cindy", "Carol",
	"Grape", "Pine", "Apple", "Brocolli", "Rakuta", "Bee", "Potral", "Cafelado", "Eidite", "Gourmon", "Freya",
	"Inglis", "Goriath"
]

static func generate():
	var random:Random = Random.new()
	return random.choice(NAMES)
