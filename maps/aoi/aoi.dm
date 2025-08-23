#if !defined(USING_MAP_DATUM)

	#include "aoi_defines.dm"
	#include "aoi_jobs.dm"
	#include "aoi_shuttles.dm"
	#include "aoi_telecomms.dm"
	#include "aoi_things.dm"
	#include "aoi_turfs.dm"
	#include "aoi_events.dm"

	#ifndef AWAY_MISSION_TEST //Don't include these for just testing away missions
		#include "aoi1.dmm"
		#include "aoi2.dmm"
		#include "aoi3.dmm"
	#endif

	#define USING_MAP_DATUM /datum/map/aoi

#elif !defined(MAP_OVERRIDE)

	#warn A map has already been included, ignoring Stellar Delight

#endif
