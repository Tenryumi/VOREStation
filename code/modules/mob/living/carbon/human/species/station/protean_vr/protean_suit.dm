// Okay but what if proteans could turn into a suit tho.........

/mob/living/carbon/human/proc/nano_intosuit(force)
	//Starting checks

	var/obj/item/clothing/suit/space/void/autolok/protean/psuit = locate() in contents

	if(!psuit)
		return

	if(!force && !isturf(loc))
		to_chat(src,"<span class='warning'>You can't change forms while inside something.</span>")
		return

	var/panel_was_up = FALSE
	if(client?.statpanel == "Protean")
		panel_was_up = TRUE

	handle_grasp() //It's possible to blob out before some key parts of the life loop. This results in things getting dropped at null. TODO: Fix the code so this can be done better.
	remove_micros(src, src) //Living things don't fare well in roblobs.
	if(buckled)
		buckled.unbuckle_mob()
	if(LAZYLEN(buckled_mobs))
		for(var/buckledmob in buckled_mobs)
			riding_datum.force_dismount(buckledmob)
	if(pulledby)
		pulledby.stop_pulling()
	stop_pulling()

	//Record where they should go
	var/atom/suit_spot = drop_location()

	psuit.myprotean_is_transforming = TRUE

	//Drop all our things
	var/list/things_to_drop = contents.Copy()
	var/list/things_to_not_drop = list(w_uniform,nif,l_store,r_store,wear_id,l_ear,r_ear) //And whatever else we decide for balancing.

	things_to_drop -= things_to_not_drop //Crunch the lists
	things_to_drop -= organs //Mah armbs
	things_to_drop -= internal_organs //Mah sqeedily spooch
	for(var/obj/item/clothing/suit/space/void/autolok/protean/O in things_to_drop)
		things_to_drop -= O

	for(var/obj/item/I in things_to_drop) //rip hoarders
		if(I.protean_drop_whitelist)
			continue
		drop_from_inventory(I)

	if(w_uniform && istype(w_uniform,/obj/item/clothing)) //No webbings tho. We do this after in case a suit was in the way
		var/obj/item/clothing/uniform = w_uniform
		if(LAZYLEN(uniform.accessories))
			for(var/obj/item/clothing/accessory/A in uniform.accessories)
				if(is_type_in_list(A, disallowed_protean_accessories))
					uniform.remove_accessory(null,A) //First param is user, but adds fingerprints and messages

	//Suit moves onto the player's location
	psuit.forceMove(suit_spot)

	// So that we don't see the glow mid-transformation 'cause that looks silly
	psuit.update_icon()

	//Player moves inside of the suit
	src.forceMove(psuit)

	//Play animation of turning into a SUIT!
	psuit.icon_state = "to_suit"
	psuit.visible_message("<b>[src.name]</b>'s body seems to turn to black sand and collapse into itself, only to quickly re-emerge in the shape of a full-body suit!")

	// Wait for the animation please!
	sleep(13) // The # of frames of both animations

	psuit.update_icon()
	psuit.myprotean_is_transforming = FALSE
	return

/mob/living/carbon/human/proc/nano_outofsuit(var/obj/item/clothing/suit/space/void/autolok/protean/suit, force)
	if (!suit)
		to_chat(src, "<span class='danger'>Your voidsuit form could not be found. This is a bug. If you're still a void suit, you will need admin assistance to get out of the suit.</span>")
		log_debug("PROTEAN BUG: Player tried to transform from void suit back to human, but suit was not found at loc.")
		return

	suit.myprotean_is_transforming = TRUE

	// So that we don't see the glow mid-transformation 'cause that looks silly
	suit.set_glow(FALSE)

	//Play animation of turning back into a person
	suit.icon_state = "from_suit"
	suit.visible_message("<b>\The [suit.name] seems to fall apart into fine filaments of black sand, only to inexplicably reshape and emerge as \the [src.name]</b>!")

	//Wait for a moment so the animation I spent a whole day on can finish *SOB*
	sleep(13) // The # of frames of both animations

	//Player moves to the turf of the suit
	src.forceMove(get_turf(suit))

	//Suit moves inside of the player
	suit.forceMove(src)

	suit.myprotean_is_transforming = FALSE

	// Set the suit back to whatever setting the Protean planter had it on
	suit.set_glow(suit.myprotean_wants_glow)
	return



/* -------------------------------------------------------------------------- */
/*                               Protean Helmet                               */
/* -------------------------------------------------------------------------- */

/obj/item/clothing/head/helmet/space/void/autolok/protean
	name = "nanite helmet"
	desc = "Tiny nanite particles have condensed tightly to form a striking, airtight helmet."
	icon = 'icons/mob/species/protean/protean.dmi'
	icon_state = "phelm"
	item_state = "phelm"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|BLOCKHAIR
	light_overlay = "should not use a light overlay"// After all, it already comes with its own glow as dictated by the Protean.

	var/mob/living/carbon/human/myprotean = null	// The protean who, well... IS the suit.
	var/mob/living/carbon/human/wearer = null		// The wearer of the suit. Used for onmob tomfoolery.
	var/obj/item/clothing/suit/space/void/autolok/protean/mysuit = null	// The suit that this Protean helmet belongs to.
	var/myprotean_wants_glow = TRUE 				// Whether or not the protean wants us to use the fancy glow mode
	var/image/overlay								// The glow for the item specifically
	var/image/mob_overlay							// The glow that goes on the onmob sprites!
	var/image/mob_icon								// The onmob sprite! Here for the sake of hopefully making the myprotean_wants_glow onmob overlays play nice with the sprite.

	sprite_sheets = list(
		SPECIES_HUMAN			= 'icons/inventory/head/mob_vr.dmi',
		SPECIES_TAJ 			= 'icons/inventory/head/mob_vr_tajaran.dmi',
		SPECIES_SKRELL 			= 'icons/inventory/head/mob_vr.dmi',
		SPECIES_UNATHI 			= 'icons/inventory/head/mob_vr_unathi.dmi',
		SPECIES_XENOHYBRID 		= 'icons/inventory/head/mob_vr_unathi.dmi',
		SPECIES_AKULA			= 'icons/inventory/head/mob_vr_akula.dmi',
		SPECIES_SERGAL			= 'icons/inventory/head/mob_vr_sergal.dmi',
		SPECIES_VULPKANIN		= 'icons/inventory/head/mob_vr_vulpkanin.dmi',
		SPECIES_ZORREN_HIGH		= 'icons/inventory/head/mob_vr_vulpkanin.dmi',
		SPECIES_FENNEC			= 'icons/inventory/head/mob_vr_vulpkanin.dmi',
		SPECIES_TESHARI			= 'icons/inventory/head/mob_vr_teshari.dmi'
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

/obj/item/clothing/head/helmet/space/void/autolok/protean/update_icon()
	overlays.Cut()
	if (!overlay)
		overlay = image(icon, "phelm_glow")
		overlay.plane = PLANE_LIGHTING_ABOVE
	if (mysuit.can_glow())
		add_overlay(overlay)

/obj/item/clothing/head/helmet/space/void/autolok/protean/make_worn_icon(var/body_type,var/slot_name,var/inhands,var/default_icon,var/default_layer = 0,var/icon/clip_mask)
	var/image/standing = ..()
	if(slot_name == slot_head_str)
		var/species_icon = 'icons/inventory/head/mob_vr.dmi'

		// Get the mob's species icon, if any.
		if(wearer && sprite_sheets && sprite_sheets[wearer.species.get_bodytype(wearer)])
			species_icon =  sprite_sheets[wearer.species.get_bodytype(wearer)]

		// After that, add the appropriate glow overlays onto the mob icon!
		if (myprotean_wants_glow)
			mob_overlay = image(species_icon, "phelm_glow")
			mob_overlay.appearance_flags = wearer.appearance_flags
			mob_overlay.plane = PLANE_LIGHTING_ABOVE
			standing.add_overlay(mob_overlay)

	return standing

/obj/item/clothing/head/helmet/space/void/autolok/protean/New(var/owner_protean)
	..()
	if (owner_protean)
		myprotean = owner_protean

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
	species_restricted = list("exclude",SPECIES_DIONA,SPECIES_VOX) // Unless someone wants to make a Vox suit sprite!

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
	var/myprotean_wants_glow = TRUE 				// Whether or not the protean wants us to use the fancy glow mode
	var/myprotean_is_transforming = FALSE			// so that people can't grab us while we're mid-animation
	var/image/overlay 								// The glowy overlay effect, wowowow!
	var/image/mob_overlay							// The glow that goes on the onmob sprites!
	var/image/mob_icon								// The onmob sprite! Here for the sake of hopefully making the glowy onmob overlays play nice with the sprite.

	sprite_sheets = list(
		SPECIES_HUMAN			= 'icons/inventory/suit/mob_vr.dmi',
		SPECIES_TAJ 			= 'icons/inventory/suit/mob_vr_tajaran.dmi',
		SPECIES_SKRELL 			= 'icons/inventory/suit/mob_vr.dmi',
		SPECIES_UNATHI 			= 'icons/inventory/suit/mob_vr_unathi.dmi',
		SPECIES_XENOHYBRID 		= 'icons/inventory/suit/mob_vr_unathi.dmi',
		SPECIES_AKULA			= 'icons/inventory/suit/mob_vr_akula.dmi',
		SPECIES_SERGAL			= 'icons/inventory/suit/mob_vr_sergal.dmi',
		SPECIES_VULPKANIN		= 'icons/inventory/suit/mob_vr_vulpkanin.dmi',
		SPECIES_ZORREN_HIGH		= 'icons/inventory/suit/mob_vr_vulpkanin.dmi',
		SPECIES_FENNEC			= 'icons/inventory/suit/mob_vr_vulpkanin.dmi',
		SPECIES_TESHARI			= 'icons/inventory/suit/mob_vr_teshari.dmi'
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

/obj/item/clothing/suit/space/void/autolok/protean/equipped(mob/living/carbon/human/M)
	..()
	if(istype(M) && M.wear_suit == src)
		wearer = M
		update_icon()

/obj/item/clothing/suit/space/void/autolok/protean/attack_hand()
	if (myprotean_is_transforming)
		return
	..()

// Item icon-specific icon glow-ination
/obj/item/clothing/suit/space/void/autolok/protean/update_icon()
	set_glow(myprotean_wants_glow)

// Onmob icon-specific icon glow-ination
/obj/item/clothing/suit/space/void/autolok/protean/make_worn_icon(var/body_type,var/slot_name,var/inhands,var/default_icon,var/default_layer = 0,var/icon/clip_mask)
	var/image/standing = ..()
	if((slot_name == slot_wear_suit_str) && can_glow() && myprotean_wants_glow)
		standing.add_overlay(mob_overlay)
		set_glow(TRUE)
	return standing

/obj/item/clothing/suit/space/void/autolok/protean/New(var/owner_protean)
	..()
	if (owner_protean)
		myprotean = owner_protean
	update_icon()

/obj/item/clothing/suit/space/void/autolok/protean/proc/set_glow(var/glow_setting)
	if (glow_setting)
		var/species_icon = 'icons/inventory/suit/mob_vr.dmi'

		// Add the appropriate glow overlays onto the mob icon!
		if (can_glow())
			mob_overlay = image(species_icon, "psuit_glow")
			mob_overlay.appearance_flags = wearer.appearance_flags
			mob_overlay.plane = PLANE_LIGHTING_ABOVE
			set_light(3, 1,  "#74fff8")
	else
		overlays.Cut()
		set_light(0)
	update_icon()

/obj/item/clothing/suit/space/void/autolok/protean/proc/can_glow()
	return is_suit_deployed() && !myprotean_is_transforming

/obj/item/clothing/suit/space/void/autolok/protean/proc/is_suit_deployed()
	// If there is no protean we belong to, I... guess the suit is technically deployed?
	if (!myprotean)
		return TRUE
	else return (!(loc == myprotean))


/obj/item/clothing/suit/space/void/autolok/protean/Initialize()
	..()
	sleep(1)
	var obj/item/clothing/head/helmet/space/void/autolok/protean/H = helmet
	if (H)
		H.myprotean = myprotean
		H.mysuit = src
