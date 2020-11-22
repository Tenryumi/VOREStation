/*
 proteans
*/
/obj/item/weapon/rig/protean
	name = "nanosuit control cluster"
	icon = 'icons/obj/rig_modules_vr.dmi'
	icon_override = 'icons/mob/rig_back_vr.dmi'
	suit_type = "nanomachine"
	icon_state = "nanomachine_rig"
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 100, rad = 100)
	emp_protection = -100 //nice.
	siemens_coefficient= 0
	slowdown = 0
	offline_slowdown = 0
	seal_delay = 1
	unremovable_cell = TRUE //it is the protean. kinda.
	var/mob/living/carbon/human/myprotean
	initial_modules = list(/obj/item/rig_module/power_sink)
	ai_override_enabled = TRUE

	helm_type = /obj/item/clothing/head/helmet/space/rig/protean
	boot_type = /obj/item/clothing/shoes/magboots/rig/protean
	chest_type = /obj/item/clothing/suit/space/rig/protean
	glove_type = /obj/item/clothing/gloves/gauntlets/rig/protean

/obj/item/weapon/rig/protean/process()
	ai_override_enabled = TRUE
	if(myprotean.nutrition > 40 && cell.charge < cell.maxcharge)
		myprotean.nutrition = max(myprotean.nutrition-10, 45)
		cell.give(7000/450*10) //this is the same amount of power as a cyborg station uses btw
	..()

/obj/item/weapon/rig/protean/relaymove(mob/user, var/direction)
	if(user.stat || user.stunned)
		return
	forced_move(direction, user, FALSE)

/obj/item/clothing/head/helmet/space/rig/protean
	name = "mass"
	desc = "A helmet-shaped clump of nanomachines."
	icon = 'icons/obj/clothing/hats_vr.dmi'
	icon_override = 'icons/mob/head_vr.dmi'
	siemens_coefficient= 0
	light_overlay = "should not use a light overlay"
	species_restricted = list(SPECIES_HUMAN, SPECIES_PROMETHEAN, SPECIES_VASILISSAN, SPECIES_ALRAUNE) //anything that's roughly humanoid ie uses human spritesheets

/obj/item/clothing/gloves/gauntlets/rig/protean
	name = "mass"
	desc = "Glove-shaped clusters of nanomachines."
	icon = 'icons/obj/clothing/gloves_vr.dmi'
	icon_override = 'icons/mob/hands_vr.dmi'
	siemens_coefficient= 0
	species_restricted = list(SPECIES_HUMAN, SPECIES_PROMETHEAN, SPECIES_VASILISSAN, SPECIES_ALRAUNE) //anything that's roughly humanoid.

/obj/item/clothing/shoes/magboots/rig/protean
	name = "mass"
	desc = "Boot-shaped clusters of nanomachines."
	icon = 'icons/obj/clothing/shoes_vr.dmi'
	icon_override = 'icons/mob/feet_vr.dmi'
	siemens_coefficient= 0
	species_restricted = list(SPECIES_HUMAN, SPECIES_PROMETHEAN, SPECIES_VASILISSAN, SPECIES_ALRAUNE) //anything that's roughly humanoid.

/obj/item/clothing/suit/space/rig/protean
	name = "mass"
	desc = "A body-hugging mass of nanomachines."
	icon = 'icons/obj/clothing/spacesuits_vr.dmi'
	icon_override = 'icons/mob/spacesuit_vr.dmi'
	siemens_coefficient= 0
	can_breach = 0
	species_restricted = list(SPECIES_HUMAN, SPECIES_PROMETHEAN, SPECIES_VASILISSAN, SPECIES_ALRAUNE) //anything that's roughly humanoid, ie uses human spritesheets
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton,/obj/item/weapon/storage/backpack,/obj/item/device/bluespaceradio)