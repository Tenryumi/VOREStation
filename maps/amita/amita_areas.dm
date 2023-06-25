
/area/amita
	name = "\improper Amita"
	icon = 'icons/turf/areas_vr.dmi'
	requires_power = TRUE
	dynamic_lighting = TRUE

/area/amita/medical
	name = "Medical Building"
	icon = 'icons/turf/areas.dmi'
	icon_state = "medbay"

/area/amita/medical/lobby
	name = "Medical Lobby"
	icon_state = "medbay4"

/area/amita/medical/chemistry
	name = "\improper Chemistry"
	icon_state = "chem"

/area/amita/medical/triage
	name = "Triage"
	icon_state = "medbay_triage"

/area/amita/medical/uppereaststairwell
	name = "\improper East Medical Stairwell"
	icon_state = "medbay_triage"

/area/amita/medical/lowereaststairwell
	name = "\improper East Medical Stairwell"
	icon_state = "medbay_triage"

/area/amita/medical/upperhalls
	name = "Upper Medical Halls"

/area/amita/medical/storage
	name = "\improper Medical Storage"
	icon_state = "medbay_primary_storage"

/area/amita/medical/breakroom
	name = "Medical Break Room"
	icon_state = "medbay_breakroom"

/area/amita/medical/patient_a
	name = "\improper Patient Room A"
	icon_state = "medbay_patient_room_a"

/area/amita/medical/patient_b
	name = "\improper Patient Room B"
	icon_state = "medbay_patient_room_b"

/area/amita/medical/patient_c
	name = "\improper Patient Room C"
	icon_state = "medbay_patient_room_c"

/area/amita/medical/recoveryward
	name = "\improper Medbay Recovery Ward"
	icon_state = "Sleep"

/area/amita/medical/resleeving
	name = "\improper Resleeving"
	icon_state = "cloning"

/area/amita/medical/cmo
	name = "Chief Medical Officer's Office"
	icon_state = "cmo"

/area/amita/medical/morgue
	name = "Morgue"
	icon_state = "medbay4"

//
// Surface Z Levels
//

/area/amita/level1
	name = "\improper Amita - Level 1"

/area/amita/level2
	name = "\improper Amita - Level 2"

/area/amita/level3
	name = "\improper Amita - Level 3"

/area/maintenance/amita
	name = "Maintenance"
	icon = 'icons/turf/areas_vr.dmi'
	icon_state = "purblasqu"
	flags = RAD_SHIELDED
	ambience = AMBIENCE_MAINTENANCE

/area/amita/outside
	name = "Outdoors"
	sound_env = SOUND_ENVIRONMENT_PLAIN

/area/amita/outside/outside1
	icon_state = "outside1"
/area/amita/outside/outside2
	icon_state = "outside2"
/area/amita/outside/outside3
	icon_state = "outside3"

/area/amita/outside/empty
	name = "Outside - Empty Area"

//
// Underground Z Levels
//

/area/amita/underground
	name = "Underground"
	flags = RAD_SHIELDED
	sound_env = SOUND_ENVIRONMENT_CAVE

//
// Underground (Depth 1)
//

/area/amita/underground/depth1
	name = "Underground - Depth 1"
	flags = RAD_SHIELDED
	sound_env = SOUND_ENVIRONMENT_CAVE

/area/maintenance/amita/underground/depth1
	name = "Maintenance - Underground (Depth 1)"
	ambience = SOUND_ENVIRONMENT_CAVE

//
// Underground (Depth 2)
//

/area/maintenance/amita/underground/depth1
	name = "Maintenance - Underground (Depth 2)"
	ambience = SOUND_ENVIRONMENT_CAVE

/area/amita/underground/depth2
	name = "Underground - Depth 2"
