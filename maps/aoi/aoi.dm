#if !defined(USING_MAP_DATUM)

	#include "aoi_defines.dm"
	#include "aoi_turfs.dm"

	#ifndef AWAY_MISSION_TEST //Don't include these for just testing away missions
		#include "aoi1.dmm"
		#include "aoi2.dmm"
	#endif

	#define USING_MAP_DATUM /datum/map/aoi

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Aoi

#endif
