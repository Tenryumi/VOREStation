// Okay but what if protean blobs could turn into a suit tho.........


/mob/living/carbon/human/proc/nano_intosuit()
    var/obj/item/clothing/suit/space/protean/psuit = loc
    src.forceMove(get_turf(psuit))
    psuit.forceMove(src)
    psuit.icon_state = "from_suit"
    psuit.visible_message = "<b>[src.name]</b>' collapses and reforms their body into a suit!"
    sleep(13) // The # of frames of both animations
    psuit.update_icon()
    return

/mob/living/carbon/human/proc/nano_outofsuit()
    var/obj/item/clothing/suit/space/protean/psuit
    for(var/obj/item/clothing/suit/space/protean/O in contents)
        psuit = O
        break
    if(psuit)
        psuit.forceMove(get_turf(src))
        src.forceMove(psuit)
    psuit.icon_state = "to_suit"
    psuit.visible_message = "<b>[src.name]</b>' collapses and reforms their body into a suit!"
    sleep(13) // The # of frames of both animations
    psuit.update_icon()
    return

// The actual suit

/obj/item/clothing/head/helmet/space/protean
	name = "nanite helmet"
	desc = "A tough shell of nanomachines morphed into the form of a helmet."
	icon = 'icons/obj/clothing/hats_vr.dmi'
	icon_override = 'icons/mob/head_vr.dmi'
	icon_state = "protean"
	siemens_coefficient= 0
	light_overlay = "should not use a light overlay"
	species_restricted = list(SPECIES_HUMAN, SPECIES_PROMETHEAN, SPECIES_VASILISSAN, SPECIES_ALRAUNE) //anything that's roughly humanoid ie uses human spritesheets

/obj/item/clothing/suit/space/protean
	name = "nanite suit"
	desc = "A swarm of nanomachines packed tightly together to create a space suit. It looks like it clings a little tightly..."
	icon = 'icons/mob/species/protean/protean.dmi' // this way we can use the transformation animations
	icon_override = 'icons/mob/spacesuit_vr.dmi'
	icon_state = "protean"
	siemens_coefficient= 0
	can_breach = 0
	species_restricted = list(SPECIES_HUMAN, SPECIES_PROMETHEAN, SPECIES_VASILISSAN, SPECIES_ALRAUNE) //anything that's roughly humanoid, ie uses human spritesheets
	allowed = list(/obj/item/weapon/gun,/obj/item/device/flashlight,/obj/item/weapon/tank,/obj/item/device/suit_cooling_unit,/obj/item/weapon/melee/baton,/obj/item/weapon/storage/backpack,/obj/item/device/bluespaceradio)