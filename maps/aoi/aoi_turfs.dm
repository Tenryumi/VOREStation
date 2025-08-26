#define AOI_ONE_ATMOSPHERE	92.5 //kPa
#define AOI_AVG_TEMP		288.15 //kelvin

#define AOI_PER_N2			0.78 //percent
#define AOI_PER_O2			0.21
#define AOI_PER_N2O			0.00 //Currently no capacity to 'start' a turf with this. See turf.dm
#define AOI_PER_CO2			0.01
#define AOI_PER_PHORON		0.00

//Math only beyond this point
#define AOI_MOL_PER_TURF	(AOI_ONE_ATMOSPHERE*CELL_VOLUME/(AOI_AVG_TEMP*R_IDEAL_GAS_EQUATION))
#define AOI_MOL_N2			(AOI_MOL_PER_TURF * AOI_PER_N2)
#define AOI_MOL_O2			(AOI_MOL_PER_TURF * AOI_PER_O2)
#define AOI_MOL_N2O			(AOI_MOL_PER_TURF * AOI_PER_N2O)
#define AOI_MOL_CO2			(AOI_MOL_PER_TURF * AOI_PER_CO2)
#define AOI_MOL_PHORON		(AOI_MOL_PER_TURF * AOI_PER_PHORON)

//Turfmakers
#define AOI_SET_ATMOS	nitrogen=AOI_MOL_N2;oxygen=AOI_MOL_O2;carbon_dioxide=AOI_MOL_CO2;phoron=AOI_MOL_PHORON;temperature=AOI_AVG_TEMP
#define AOI_TURF_CREATE(x)	x/aoi/nitrogen=AOI_MOL_N2;x/aoi/oxygen=AOI_MOL_O2;x/aoi/carbon_dioxide=AOI_MOL_CO2;x/aoi/phoron=AOI_MOL_PHORON;x/aoi/temperature=AOI_AVG_TEMP;x/aoi/outdoors=TRUE;x/aoi/update_graphic(list/graphic_add = null, list/graphic_remove = null) return 0
#define AOI_TURF_CREATE_INDOOR(x)	x/aoi/indoors/nitrogen=AOI_MOL_N2;x/aoi/indoors/oxygen=AOI_MOL_O2;x/aoi/indoors/carbon_dioxide=AOI_MOL_CO2;x/aoi/indoors/phoron=AOI_MOL_PHORON;x/aoi/indoors/temperature=AOI_AVG_TEMP;x/aoi/indoors/outdoors=FALSE;x/aoi/indoors/update_graphic(list/graphic_add = null, list/graphic_remove = null) return 0
#define AOI_TURF_CREATE_UN(x)	x/aoi/nitrogen=AOI_MOL_N2;x/aoi/oxygen=AOI_MOL_O2;x/aoi/carbon_dioxide=AOI_MOL_CO2;x/aoi/phoron=AOI_MOL_PHORON;x/aoi/temperature=AOI_AVG_TEMP

#define AOI_TUMMYWALL_DESC "The whale's inner flesh gently pulses and ripples, a heart of inconceivable scale tirelessly pumping blood throughout every vein and artery lining these very floors."

// Whale guts
/turf/simulated/floor/flesh/aoi
	desc = AOI_TUMMYWALL_DESC

/turf/simulated/floor/flesh/aoi/outdoors
	outdoors = TRUE

/turf/simulated/flesh/aoi
	desc = AOI_TUMMYWALL_DESC

/turf/simulated/flesh/aoi/outdoors
	outdoors = TRUE

/turf/simulated/flesh/colour/aoi
	desc = AOI_TUMMYWALL_DESC

// Back turfs

AOI_TURF_CREATE(/turf/simulated/floor/tiled/steel_dirty)
AOI_TURF_CREATE(/turf/simulated/floor)
AOI_TURF_CREATE(/turf/simulated/mineral/floor)
AOI_TURF_CREATE(/turf/simulated/floor/outdoors/newdirt)
AOI_TURF_CREATE(/turf/simulated/floor/outdoors/newdirt_nograss)
AOI_TURF_CREATE(/turf/simulated/open)
AOI_TURF_CREATE_INDOOR(/turf/simulated/mineral/floor)
AOI_TURF_CREATE_INDOOR(/turf/simulated/floor/outdoors/newdirt)
AOI_TURF_CREATE_INDOOR(/turf/simulated/floor/outdoors/newdirt_nograss)
AOI_TURF_CREATE_INDOOR(/turf/simulated/open)


#undef AOI_ONE_ATMOSPHERE
#undef AOI_AVG_TEMP

#undef AOI_PER_N2
#undef AOI_PER_O2
#undef AOI_PER_N2O
#undef AOI_PER_CO2
#undef AOI_PER_PHORON

#undef AOI_MOL_PER_TURF
#undef AOI_MOL_N2
#undef AOI_MOL_O2
#undef AOI_MOL_N2O
#undef AOI_MOL_CO2
#undef AOI_MOL_PHORON

#undef AOI_SET_ATMOS
#undef AOI_TURF_CREATE
#undef AOI_TURF_CREATE_UN
