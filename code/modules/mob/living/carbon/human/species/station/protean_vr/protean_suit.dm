// Okay but what if protean blobs could turn into a suit tho.........

/mob/living/carbon/human/proc/nano_intosuit()
	var/obj/item/clothing/suit/space/void/autolok/protean/psuit = loc
	src.forceMove(get_turf(psuit))
	psuit.forceMove(src)
	psuit.icon_state = "from_suit"
	psuit.visible_message("<b>[src.name]</b> collapses and reforms their body into a suit!")
	sleep(13) // The # of frames of both animations
	psuit.update_icon()
	return

/mob/living/carbon/human/proc/nano_outofsuit()
	var/obj/item/clothing/suit/space/void/autolok/protean/psuit
	for(var/obj/item/clothing/suit/space/void/autolok/protean/O in contents)
		psuit = O
		break
	if(psuit)
		psuit.forceMove(get_turf(src))
		src.forceMove(psuit)
	psuit.icon_state = "to_suit"
	psuit.visible_message("<b>[src.name]</b> reshapes into a humanoid appearance!")
	sleep(13) // The # of frames of both animations
	psuit.update_icon()
	return

// The actual suit
/obj/item/clothing/head/helmet/space/void/autolok/protean
	name = "nanite helmet"
	desc = "A tough shell of nanomachines morphed into the form of a helmet."
	icon = 'icons/obj/clothing/hats_vr.dmi'
	icon_override = 'icons/mob/head_vr.dmi'
	icon_state = "phelm"
	light_overlay = "should not use a light overlay"
	var/glowy = TRUE // Whether or not the protean wants us to use the fancy glow mode
	var/image/overlay
	
	sprite_sheets = list(
		SPECIES_HUMAN			= 'icons/mob/head_vr.dmi',
		SPECIES_TAJ 			= 'icons/mob/species/tajaran/helmet_vr.dmi',
		SPECIES_SKRELL 			= 'icons/mob/species/skrell/helmet_vr.dmi',
		SPECIES_UNATHI 			= 'icons/mob/species/unathi/helmet_vr.dmi',
		SPECIES_XENOHYBRID 		= 'icons/mob/species/unathi/helmet_vr.dmi',
		SPECIES_AKULA			= 'icons/mob/species/akula/helmet_vr.dmi',
		SPECIES_SERGAL			= 'icons/mob/species/unathi/helmet_vr.dmi',
		SPECIES_VULPKANIN		= 'icons/mob/species/vulpkanin/helmet_vr.dmi',
		SPECIES_ZORREN_HIGH		= 'icons/mob/species/vulpkanin/helmet_vr.dmi',
		SPECIES_FENNEC			= 'icons/mob/species/vulpkanin/helmet_vr.dmi',
		SPECIES_TESHARI			= 'icons/mob/species/seromi/helmet_vr.dmi'
		)
	sprite_sheets_obj = list(
		SPECIES_TAJ				= 'icons/mob/species/protean/protean.dmi',
		SPECIES_SKRELL			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_UNATHI			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_XENOHYBRID		= 'icons/mob/species/protean/protean.dmi',
		SPECIES_AKULA			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_SERGAL			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_VULPKANIN		= 'icons/mob/species/protean/protean.dmi',
		SPECIES_ZORREN_HIGH		= 'icons/mob/species/protean/protean.dmi',
		SPECIES_FENNEC			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_TESHARI			= 'icons/mob/species/protean/protean.dmi'
		)
	sprite_sheets_refit = list()	//have to nullify this as well just to be thorough

/obj/item/clothing/head/helmet/space/void/autolok/protean/update_icon()
	if (!overlay)
		overlay = image(icon, "phelm_glow")
		overlay.plane = PLANE_LIGHTING_ABOVE
	
	overlays.Cut()
	if (glowy)
		overlays += overlay
		icon_state = "phelm_glowing"
		set_light(2, 0.1,  "#74fff8")
	else
		icon_state = "phelm"
		set_light(0)
	

/obj/item/clothing/suit/space/void/autolok/protean
	name = "nanite suit"
	desc = "A swarm of nanomachines packed tightly together to create a space suit. It looks like it clings a little tightly..."
	icon = 'icons/mob/species/protean/protean.dmi' // this way we can use the transformation animations
	icon_override = 'icons/mob/spacesuit_vr.dmi'
	icon_state = "psuit"
	can_breach = 0 // Please do not breach the Protean
	slowdown = 0 // This is about as lightweight as it gets, proteans can make themselves EXTREMELY lightweight if they want to
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton,/obj/item/weapon/storage/backpack,/obj/item/device/bluespaceradio)
	helmet_type = /obj/item/clothing/head/helmet/space/void/autolok/protean
	var/glowy = TRUE // Whether or not the protean wants us to use the fancy glow mode
	var/image/overlay // The glowy overlay effect, wowowow!
	var/transforming = FALSE // so that people can't grab us while we're mid-animation
	var/mob/living/carbon/human/myprotean = null

	sprite_sheets = list(
		SPECIES_HUMAN			= 'icons/mob/spacesuit_vr.dmi',
		SPECIES_TAJ 			= 'icons/mob/species/tajaran/suit_vr.dmi',
		SPECIES_SKRELL 			= 'icons/mob/spacesuit_vr.dmi',
		SPECIES_UNATHI 			= 'icons/mob/species/unathi/suit_vr.dmi',
		SPECIES_XENOHYBRID 		= 'icons/mob/species/unathi/suit_vr.dmi',
		SPECIES_AKULA			= 'icons/mob/species/akula/suit_vr.dmi',
		SPECIES_SERGAL			= 'icons/mob/species/unathi/suit_vr.dmi',
		SPECIES_VULPKANIN		= 'icons/mob/species/vulpkanin/suit_vr.dmi',
		SPECIES_ZORREN_HIGH		= 'icons/mob/species/vulpkanin/suit_vr.dmi',
		SPECIES_FENNEC			= 'icons/mob/species/vulpkanin/suit_vr.dmi',
		SPECIES_TESHARI			= 'icons/mob/species/seromi/suit_vr.dmi'
		)
	sprite_sheets_obj = list(
		SPECIES_TAJ				= 'icons/mob/species/protean/protean.dmi',
		SPECIES_SKRELL			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_UNATHI			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_XENOHYBRID		= 'icons/mob/species/protean/protean.dmi',
		SPECIES_AKULA			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_SERGAL			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_VULPKANIN		= 'icons/mob/species/protean/protean.dmi',
		SPECIES_ZORREN_HIGH		= 'icons/mob/species/protean/protean.dmi',
		SPECIES_FENNEC			= 'icons/mob/species/protean/protean.dmi',
		SPECIES_TESHARI			= 'icons/mob/species/protean/protean.dmi'
		)
	sprite_sheets_refit = list()	//have to nullify this as well just to be thorough

/obj/item/clothing/suit/space/void/autolok/protean/attack_hand(var/mob/user)
	if (transforming)
		return
	..()

/obj/item/clothing/suit/space/void/autolok/protean/update_icon()
	if (!overlay)
		overlay = image(icon, "psuit_glow")
		overlay.plane = PLANE_LIGHTING_ABOVE
	
	overlays.Cut()
	if (glowy)
		overlays += overlay
		icon_state = "psuit_glowing"
		set_light(2, 0.1,  "#74fff8")
	else
		icon_state = "psuit"
		set_light(0)
