extends Node

var occupants:Array = []
var recruit = null
var in_other_party:bool = false
var party_leader = null
var follow_target = null
var targets:Array = []
var current_target = null
const max_party_slots:int = 2


func add_party_member(member, memberdata):
	if in_other_party:
		party_leader.add_party_member(member,memberdata)
		
	else:	
		memberdata.follow_target = occupants[occupants.size() - 1].member if occupants.size() > 0 else get_parent()
		occupants.push_back({"member":member,"data":memberdata})
		memberdata.in_other_party = true
		memberdata.party_leader = self
		
	
func party_is_recruiting(memberdata)->bool:
	if memberdata.occupants.size() > 0:
		return false
	if occupants.size() < max_party_slots and !in_other_party:
		return true
	if in_other_party and party_leader.party_is_recruiting(memberdata):
		return true
	return false

func remove_party_member(member, memberdata):
	if in_other_party:
		party_leader.remove_party_member(member, memberdata)
	elif occupants.size() > 0:
		occupants.erase({"member":member, "data":memberdata})
		memberdata.in_other_party = false
		memberdata.party_leader = null


