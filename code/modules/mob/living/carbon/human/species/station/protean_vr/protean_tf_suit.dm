/datum/temporary_transformation/protean/voidsuit
	abstract_type = FALSE

	var/obj/item/clothing/suit/space/void/autolok/protean/suit = null
	var/obj/item/clothing/head/helmet/space/void/autolok/protean/helmet = null

	var/wants_to_glow = TRUE // Is toggled on and off at the Protean player's will.

/datum/temporary_transformation/protean/voidsuit/New(var/mob/living/carbon/human/tf_owner)
	. = ..()
	suit = new /obj/item/clothing/suit/space/void/autolok/protean(tf_owner)
	var/obj/item/clothing/head/helmet/space/void/autolok/protean/H = suit.helmet
	if (H)
		helmet = H

/datum/temporary_transformation/protean/voidsuit/enter_form(force)
	var/mob/living/carbon/human/O = src.owner
	if (!O)
		return FALSE
	//Starting checks

	var/obj/item/clothing/suit/space/void/autolok/protean/S = suit

	if(!S)
		return

	if(!force && !isturf(O.loc))
		to_chat(O,"<span class='warning'>You can't change forms while inside something.</span>")
		return

	var/panel_was_up = FALSE
	if(O.client?.statpanel == "Protean")
		panel_was_up = TRUE

	release_owner()

	transforming = TRUE

	//Drop all our things
	drop_owner_contents()

	//Record where they should go
	var/atom/suit_spot = O.drop_location()

	//Suit moves onto the player's location
	S.forceMove(suit_spot)

	// So that we don't see the glow mid-transformation 'cause that looks silly
	S.update_icon()

	//Player moves inside of the suit
	O.forceMove(S)

	//Play animation of turning into a SUIT!
	S.icon_state = "to_suit"
	S.visible_message("<b>\The [O.name]</b>'s body appears to turn into black sand and collapses into itself, only to quickly re-emerge in the shape of a strange suit!", null, list(O))
	to_chat(O, "<span class='notice'>Your body collapses into itself as if it were nothing more than fine sand. Just as quickly as you fell apart, you re-emerge with a new, solid form in the shape of... A suit?</span>")

	// Wait for the animation please!
	sleep(13) // The # of frames of both animations

	S.update_icon()
	S.myprotean_is_transforming = FALSE
	return

/datum/temporary_transformation/protean/voidsuit/exit_form(force)
	var/mob/living/carbon/human/O = src.owner
	if (!O)
		log_debug("<span class='danger'>ERROR: Temporary transformation of type '[src.type]' can't find its owner's body (ckey: '[(ckey ? ckey : "{null}")]').</span>")
		return FALSE
	//Starting checks

	var/obj/item/clothing/suit/space/void/autolok/protean/S = suit
	if (!S)
		log_debug("<span class='danger'>ERROR: Protean suit temporary transformation of type '[src.type]' can't find its associated suit. (ckey: '[(ckey ? ckey : "{null}")]').</span>")
		to_chat(src, "<span class='danger'>Your voidsuit form could not be found. This is a bug. If you're still a void suit, you will need admin assistance to get out of your situation.</span>")
		return

	transforming = TRUE

	// So that we don't see the glow mid-transformation 'cause that looks silly
	S.set_glow(FALSE)

	//Play animation of turning back into a person
	S.icon_state = "from_suit"
	S.visible_message("<b>\The [S.name] seems to fall apart into fine filaments of black sand, only to inexplicably reshape and emerge as \the [O.name]</b>!", null, list(O))
	to_chat(O, "<span class='notice'>Your body collapses into itself as if it were nothing more than fine sand. Just as quickly as you fell apart, you re-emerge in the exact shape of your original body.</span>")
	//Wait for a moment so the animation I spent a whole day on can finish *SOB*
	sleep(13) // The # of frames of both animations

	//Player moves to the location of the suit
	O.forceMove(get_temp_form_location())

	//Suit moves inside of the player
	S.forceMove(O)

	transforming = FALSE

	// It should turn off while it technically doesn't exist!
	S.set_glow(FALSE)
	return
