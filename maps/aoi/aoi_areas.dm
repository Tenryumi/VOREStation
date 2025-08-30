/area/aoi
	name = "\improper Aoi"
	icon = 'icons/turf/areas_vr.dmi'
	icon_state = "blublacir"
	requires_power = TRUE
	dynamic_lighting = TRUE
	flags = AREA_ALLOW_LARGE_SIZE
	base_turf = /turf/simulated/mineral/floor/virgo3c

// INDOORS AREAS
/area/aoi/indoors
	icon_state = "cyawhicir"
	sound_env = SOUND_ENVIRONMENT_ROOM
	flags = AREA_FLAG_IS_NOT_PERSISTENT | AREA_ALLOW_LARGE_SIZE

/area/aoi/indoors/teleporter
	name = "\improper Transit Gateway"
	icon_state = "grewhicir"

/area/aoi/indoors/research
	name = "\improper Research Outpost"
	icon_state = "magwhicir"

/area/aoi/indoors/power
	name = "\improper Power Banks"
	icon_state = "yelwhitri"

/area/aoi/indoors/sleeve_facility
	name = "\improper Sleeve Facility"
	icon_state = "cyawhitri"

/area/aoi/indoors/tech
	name = "\improper Data Processing"
	icon_state = "magwhicir"

/area/aoi/indoors/quarters
	name = "\improper Quarters"
	icon_state = "grewhisqu"


// OUTDOORS AREAS
/area/aoi/outdoors/
	icon_state = "redblacir"
	sound_env = SOUND_ENVIRONMENT_ALLEY
	ambience = AMBIENCE_RUINS
	flags = AREA_FLAG_IS_NOT_PERSISTENT | AREA_ALLOW_LARGE_SIZE

/area/aoi/outdoors/central
	name = "\improper Central Facility"
	icon_state = "blublacir"

/area/aoi/outdoors/west
	name = "\improper West Facility"
	icon_state = "blublacir"

/area/aoi/outdoors/east
	name = "\improper East Facility"
	icon_state = "greblacir"

/area/aoi/outdoors/north
	name = "\improper North Facility"
	icon_state = "yelblacir"

/area/aoi/outdoors/solars
	name = "\improper Solar Arrays"
	icon_state = "yelblasqu"

/area/aoi/nopower
	name = "\improper Aoi"
	icon_state = "dk_yellow"
	requires_power = FALSE

// WHALE GUTS
/area/aoi/flesh
	name = "Belly of the Whale"
	icon_state = "redblatri"
	forced_ambience = list('sound/vore/stomach_loop.ogg', 'sound/vore/sunesound/prey/loop.ogg')
	semirandom = TRUE
	semirandom_groups = 1
	semirandom_group_min = 5
	semirandom_group_max = 15
	mob_intent = "retaliate"
	valid_mobs = list(
		list(
			/mob/living/simple_mob/vore/vore_hostile/abyss_lurker = 100,
			/mob/living/simple_mob/vore/vore_hostile/leaper = 100,
			/mob/living/simple_mob/vore/vore_hostile/gelatinous_cube = 10
			)
			)
	sound_env = SOUND_ENVIRONMENT_CAVE

/area/maintenance/aoi
	name = "\improper Maintenance"
	icon = 'icons/turf/areas_vr.dmi'
	icon_state = "purblasqu"
	flags = RAD_SHIELDED
	ambience = AMBIENCE_MAINTENANCE
