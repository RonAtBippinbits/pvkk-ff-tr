extends RefCounted

class_name CONST

enum BUILD_TYPE {FULL, DEMO, PLAYTEST, EXHIBITION}

const DIRECTIONS := [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const DIAGONALS := [Vector2(1,1), Vector2(-1,1), Vector2(1,-1), Vector2(-1,-1)]

const OVERLAY_COLOR_IN := Color("29190fd3")
const OVERLAY_COLOR_OUT := Color("29190f00")

const TUTORIAL_LISTENING := 1
const TUTORIAL_DISPLAYING := 2
const TUTORIAL_TIMEDOUT := 3
const TUTORIAL_CONFIRMED := 4

const MISSION_STATE_IDLE := "idle"
const MISSION_STATE_BRIEFING := "briefing"
const MISSION_STATE_BRIEFING_DONE = "briefing_done"
const MISSION_STATE_ACTIVE := "active"
const MISSION_STATE_FAILED := "failed"
const MISSION_STATE_DEBRIEFING := "debriefing"
const MISSION_STATE_TEATIME := "teatime"
const MISSION_STATE_FINISHED := "finished"

const AMMO_KWG := "kwg"
const AMMO_HE := "he"
const AMMO_SM := "sm"
const AMMO_PGM := "pgm"
const AMMO_FLAK := "flak"

const AMMO_ALL := [AMMO_KWG, AMMO_HE, AMMO_SM, AMMO_PGM, AMMO_FLAK]

const OK := "ok"
const ERROR := "error"
const NONE := "none"

const ON := "on"
const OFF := "off"
const CHARGING := "charging"
const CHARGING_NORMAL := "charging_normal"
const CHARGING_FAST := "charging_fast"
const CAN_BOOST := "can_boost"
const ACTIVE := "active"

const PHYSICS_LAYER_SHIPS = 9
const PHYSICS_LAYER_PROJECTILES = 10

const MAXIMUM_WATT_USAGE := 120.0

const COL_RED := Color(1.0, 0.15, 0.05, 1.0)
const COL_YELLOW := Color(1, 0.843137, 0.05, 1)
const COL_GREEN := Color(0.05, 0.75, 0.8, 1)
const COL_EXTRA := Color(0.117647, 0.564706, 1, 1)

const COL_DISPLAY_YELLOW := Color(1.0, 0.706, 0.0, 1.0)
const COL_DISPLAY_YELLOW_LIGHT := Color(1.0, 0.839, 0.471, 1.0)


const MISSIONSTATS_RATINGS = {
	-10: "Very Bad",
	-7: "Bad",
	-4: "Average",
	-1: "Passable",
	1: "Good",
	3: "Great",
	6: "Honourable",
	10: "Heroic",
}

const SOUND_DELAY_CITY := 0.8

const TELERADIO_U := "▲"
const TELERADIO_D := "▼"
const TELERADIO_R := "►"
const TELERADIO_L := "◄"

static var COMPARISONS := {
	"==" = func(a, b) -> bool: return a == b,
	"!=" = func(a, b) -> bool: return a != b,
	">=" = func(a, b) -> bool: return a >= b,
	"<=" = func(a, b) -> bool: return a <= b,
	"<" = func(a, b) -> bool: return a < b,
	">" = func(a, b) -> bool: return a > b,
}

const FORBIDDEN_SHIP_SERIAL_NUMBERS := [1453]

const EXAMS := {
	
	"advanced_mechanist" : {
	
	"title" : "Advanced Mechanist",
 	"intro" : "You are about to embark on the Level 2 PVKK Examination, an assessment designed to evaluate your knowledge, skills, and understanding of operational procedures, safety protocols, and maintenance practices, with a special focus on managing and preventing Verkantungen (misalignments or jamming) in complex machinery.
This examination is a crucial step in certifying your competence to operate and maintain industrial machinery in a safe, efficient, and effective manner. It is structured to test both theoretical knowledge and practical insights drawn from real-world scenarios you may encounter in your role as a PVKK.",
	"outro" : "Congratulations! Your advancement to Level 2 has been noted. Use this knowledge to continue protecting our country.",
	
	"questions" : [
	{
		"question" : "During a routine inspection, you notice a slight Verkantung in the clutch mechanism. What is the first step?",
		"answers" : ["Continue working and hope the Verkantung resolves itself as it is minor.",
					"Use a hammer to fix the Verkantung.",
					"Immediately shut down the machine and report the Verkantung."],
		"correct" : 3,
	},
	{
		"question" : "After resolving a Verkantung, your next step should be:",
		"answers" : ["Restart the machine immediately.",
					"Conduct a thorough inspection to ensure there are no further issues.",
					"Take a break."],
		"correct" : 2,
	},
	{
		"question" : "If a Verkantung occurs during a critical operational process, you should:",
		"answers" : ["Continue the operation and fix the Verkantung later.",
					"Immediately and safely shut down the machine and report the problem.",
					"Ignore the Verkantung as the operational process takes priority."],
		"correct" : 2,
	},
	{
		"question" : "A Verkantung is often the result of:",
		"answers" : ["Excessive lubrication.",
					"Too low operating temperature.",
					"Lack of maintenance and checking."],
		"correct" : 3,
	},
	{
		"question" : "Before attempting to fix a Verkantung, you should:",
		"answers" : ["Put on safety goggles.",
					"Grab the nearest hammer.",
					"Keep the machine running."],
		"correct" : 1,
	},
	{
		"question" : "Which regular maintenance action can help prevent Verkantungen?",
		"answers" : ["Regularly lubricate moving parts.",
					"Run the machine in a cold state.",
					"Use the universal tool for all repairs."],
		"correct" : 1,
	},
	{
		"question" : "When a Verkantung occurs, it is important to first:",
		"answers" : ["Identify the cause of the Verkantung.",
					"Forcefully resolve the Verkantung.",
					"Take a tea break."],
		"correct" : 1,
	},
	{
		"question" : "Verkantungen can increase the risk of which of the following problems?",
		"answers" : ["Decreased efficiency.",
					"Lower energy consumption.",
					"Improved machine performance."],
		"correct" : 1,
	},
	{
		"question" : "When reporting a Verkantung, you should:",
		"answers" : ["Specify the exact location and nature of the Verkantung.",
					"Exaggerate the Verkantung to get quick help.",
					"Downplay the Verkantung to avoid causing panic."],
		"correct" : 1,
	},
	{
		"question" : "In the case of a severe Verkantung that cannot be immediately resolved, you should:",
		"answers" : ["Keep the machine operational and hope for the best.",
					"Secure the area and contact maintenance.",
					"Try to fix the Verkantung with improvised tools."],
		"correct" : 2,
	}
	]
},

	"report46" : {
	
	"title" : "Report #46 Verification",
 	"intro" : "Please complete the following exam to verify your understanding of the critical information provided in Report #46.",
	"outro" : "Your acknowledgement of the report has been noted. It is imperative to act on the conclusions of Report #46\
	immediately. Make sure to store all dangerous units in the entrance safe. (Code 46-03-10)",
	
	"questions" : [
	{
		"question" : "WIP",
		"answers" : ["CORRECT",
					"WRONG",
					"WRONG"],
		"correct" : 1,
	}
	]
},
}

const MESSAGES := {
	
	"safe_access_denied":{
	"title" : "15-10-2488: Safe Access Request Denied",
	"sender" : "Planetary Defense Logistics - Support Officer #5993",
	"message" : "Your request for the entrance room safe access code has been: DENIED. \n
	PDLM 144.03.b	  : Safe Code access requires security clearance 3A or above.
	PD 2488.10.03.07.a: Safe Code access security clearance requirement has been raised to 5B or above due to Report #46.
	"
	},
	
	"report46":{
	"title" : "03-10-2488: Report #46",
	"sender" : "Planetary Defense Logistics - Supplies and Nourishment",
	"message" : "Effective immediately all cans of 'Schmieri™ Extra' are to be locked up in the safe until further notice.
	Recent reports by the PDSO show an increased consumptions rate among Planetenverteidigungskanonenkommandanten indicative of a type 2 addiction. 
	
	Safe Guidelines:
	The safe can be accessed with the standardized code: 21 07 36. 
	Upon correctly entering all three digits, the security light will light up, signaling  that the handle is now safe to operate.
	"
	},
	
}


static func lerp_rotation(rot:Vector3, target:Vector3, delta:float):
	var result := rot
	result.x = lerp_angle(result.x, target.x, delta)
	result.y = lerp_angle(result.y, target.y, delta)
	result.z = lerp_angle(result.z, target.z, delta)
	return result
