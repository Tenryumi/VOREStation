// Okay but what if proteans could turn into a suit tho.........

/mob/living/carbon/human/proc/nano_intosuit(var/obj/item/clothing/suit/space/void/autolok/protean/psuit)
	//Starting checks
	if(!psuit)
		return
	psuit.transforming = TRUE
	
	// So that we don't see the glow mid-transformation 'cause that looks silly
	if (psuit.glowy)
		psuit.glowy = FALSE
		psuit.update_icon()
		psuit.glowy = TRUE
	
	//Suit moves onto the player's turf
	psuit.forceMove(get_turf(src))
	
	//Player moves inside of the suit
	src.forceMove(psuit)
	
	//Play animation of turning into a SUIT!
	psuit.icon_state = "to_suit"
	psuit.visible_message("<b>[src.name]</b> collapses and reforms their body into a suit!")
	
	// Wait for the animation please!
	sleep(13) // The # of frames of both animations

	psuit.update_icon()
	psuit.transforming = FALSE
	return

/mob/living/carbon/human/proc/nano_outofsuit()
	var/obj/item/clothing/suit/space/void/autolok/protean/psuit = loc
	psuit.transforming = TRUE

	// So that we don't see the glow mid-transformation 'cause that looks silly
	if (psuit.glowy)
		psuit.glowy = FALSE
		psuit.update_icon()
		psuit.glowy = TRUE
	
	//Play animation of turning back into a hu-mon
	psuit.icon_state = "from_suit"
	psuit.visible_message("<b>[src.name]</b> reshapes into a humanoid appearance!")
	
	//Wait for a moment so the animation I spent a whole day on can finish *SOB*
	sleep(13) // The # of frames of both animations

	//Player moves to the turf of the suit
	src.forceMove(get_turf(psuit))

	//Suit moves inside of the player
	psuit.forceMove(src)

	psuit.update_icon()
	psuit.transforming = FALSE
	return



/* -------------------------------------------------------------------------- */
/*                               Protean Helmet                               */
/* -------------------------------------------------------------------------- */

/obj/item/clothing/head/helmet/space/void/autolok/protean
	name = "nanite helmet"
	desc = "A tough shell of nanomachines morphed into the form of a helmet."
	icon = 'icons/obj/clothing/hats_vr.dmi'
	icon_state = "phelm"
	item_state = "phelm"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	light_overlay = "should not use a light overlay"// After all, it already comes with its own glow as dictated by the Protean.
	
	var/mob/living/carbon/human/myprotean = null	// The protean who, well... IS the suit.
	var/mob/living/carbon/human/wearer = null		// The wearer of the suit. Used for onmob tomfoolery.
	var/glowy = TRUE 								// Whether or not the protean wants us to use the fancy glow mode
	var/image/overlay								// The glow for the item specifically
	var/image/mob_overlay							// The glow that goes on the onmob sprites!
	var/image/mob_icon								// The onmob sprite! Here for the sake of hopefully making the glowy onmob overlays play nice with the sprite.
	
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
	overlays.Cut()
	if (!overlay)
		overlay = image(icon, "phelm_glow")
		overlay.plane = PLANE_LIGHTING_ABOVE
	if (glowy)
		add_overlay(overlay)
		set_light(3, 1,  "#74fff8")
	else
		set_light(0)

/obj/item/clothing/head/helmet/space/void/autolok/protean/make_worn_icon(var/body_type,var/slot_name,var/inhands,var/default_icon,var/default_layer = 0,var/icon/clip_mask)
	var/image/standing = ..()
	if(slot_name == slot_head_str)
		var/species_icon = 'icons/mob/spacesuit_vr.dmi'

		// Get the mob's species icon, if any.
		if(wearer && sprite_sheets && sprite_sheets[wearer.species.get_bodytype(wearer)])
			species_icon =  sprite_sheets[wearer.species.get_bodytype(wearer)]
		
		// After that, add the appropriate glow overlays onto the mob icon!
		if (glowy)
			mob_overlay = image(species_icon, "phelm_glow")
			mob_overlay.appearance_flags = wearer.appearance_flags
			mob_overlay.plane = PLANE_LIGHTING_ABOVE
			standing.add_overlay(mob_overlay)
		
	return standing

/obj/item/clothing/head/helmet/space/void/autolok/protean/New(var/owner_protean)
	..()
	if (owner_protean)
		myprotean = owner_protean
	update_icon()

/obj/item/clothing/head/helmet/space/void/autolok/protean/relaymove()
	if(recent_struggle)
		return

	recent_struggle = 1

	spawn(100)
		recent_struggle = 0

	if(ishuman(src.loc))
		var/mob/living/carbon/human/H = src.loc
		H.visible_message("<span class='notice'>[src] wiggles its sleeves and leggings a little. That's... totally not creepy.</span>", \
						"You wiggle your arms and legs... Which at the moment are sleeves and leggings. This probably looks very weird.")



/* -------------------------------------------------------------------------- */
/*                                Protean Suit                                */
/* -------------------------------------------------------------------------- */

/obj/item/clothing/suit/space/void/autolok/protean
	name = "nanite suit"
	desc = "A swarm of nanomachines packed tightly together to create a space suit. It looks like it clings a little tightly..."
	icon = 'icons/mob/species/protean/protean.dmi' // this way we can use the transformation animations
	icon_state = "psuit"
	item_state = "psuit"
	can_breach = 0 		// Please do not breach the Protean
	slowdown = 0 		// This is about as lightweight as it gets, proteans can make themselves EXTREMELY lightweight if they want to
	species_restricted = list("exclude",SPECIES_DIONA,SPECIES_VOX)
	
	allowed = list(/obj/item/weapon/gun, 	\
	/obj/item/device/flashlight, 			\
	/obj/item/weapon/tank, 					\
	/obj/item/device/suit_cooling_unit, 	\
	/obj/item/weapon/melee/baton, 			\
	/obj/item/weapon/storage/backpack, 		\
	/obj/item/device/bluespaceradio)
	
	helmet_type = /obj/item/clothing/head/helmet/space/void/autolok/protean

	var/mob/living/carbon/human/myprotean = null	// The protean who, well... IS the suit.
	var/mob/living/carbon/human/wearer = null		// The wearer of the suit. Used for onmob tomfoolery.
	var/glowy = TRUE 								// Whether or not the protean wants us to use the fancy glow mode
	var/transforming = FALSE						// so that people can't grab us while we're mid-animation
	var/image/overlay 								// The glowy overlay effect, wowowow!
	var/image/mob_overlay							// The glow that goes on the onmob sprites!
	var/image/mob_icon								// The onmob sprite! Here for the sake of hopefully making the glowy onmob overlays play nice with the sprite.

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

/obj/item/clothing/suit/space/void/autolok/protean/equipped(mob/living/carbon/human/M)
	..()
	if(istype(M) && M.wear_suit == src)
		wearer = M
		update_icon()

/obj/item/clothing/suit/space/void/autolok/protean/attack_hand()
	if (transforming)
		return
	..()

// Item icon-specific icon glow-ination 
/obj/item/clothing/suit/space/void/autolok/protean/update_icon()
	overlays.Cut()
	if (!overlay)
		overlay = image(icon, "psuit_glow")
		overlay.plane = PLANE_LIGHTING_ABOVE
	if (glowy)
		add_overlay(overlay)
		set_light(3, 1,  "#74fff8")
	else
		set_light(0)

// Onmob icon-specific icon glow-ination 
/obj/item/clothing/suit/space/void/autolok/protean/make_worn_icon(var/body_type,var/slot_name,var/inhands,var/default_icon,var/default_layer = 0,var/icon/clip_mask)
	var/image/standing = ..()
	if(slot_name == slot_wear_suit_str)
		var/species_icon = 'icons/mob/spacesuit_vr.dmi'
		
		// After that, add the appropriate glow overlays onto the mob icon!
		if (glowy)
			mob_overlay = image(species_icon, "psuit_glow")
			mob_overlay.appearance_flags = wearer.appearance_flags
			mob_overlay.plane = PLANE_LIGHTING_ABOVE
			standing.add_overlay(mob_overlay)
		
	return standing

/obj/item/clothing/suit/space/void/autolok/protean/New(var/owner_protean)
	..()
	if (owner_protean)
		myprotean = owner_protean
	update_icon()

/obj/item/clothing/suit/space/void/autolok/protean/Initialize()
	..()
	sleep(1)
	helmet.myprotean = myprotean