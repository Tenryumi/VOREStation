/datum/temporary_transformation/protean/voidsuit
	var/obj/item/clothing/suit/space/void/autolok/protean/suit = null
	var/obj/item/clothing/head/helmet/space/void/autolok/protean/helmet = null

	var wants_to_glow = TRUE // Is toggled on and off at the Protean player's will.

/datum/temporary_transformation/protean/voidsuit/New(var/mob/living/carbon/human/tf_owner)
	. = ..()
	suit = new /obj/item/clothing/suit/space/void/autolok/protean(tf_owner)
	var/obj/item/clothing/head/helmet/space/void/autolok/protean/H = suit.helmet
	if (H)
		helmet = H

/datum/temporary_transformation/protean/voidsuit/enter_form(force)
	. = ..()
	var/mob/living/carbon/human/O = src.owner
	if (!O)
		return FALSE
	//Starting checks

	var/obj/item/clothing/suit/space/void/autolok/protean/S = suit

	if(!S)
		return

	if(!force && !isturf(loc))
		to_chat(src,"<span class='warning'>You can't change forms while inside something.</span>")
		return

	var/panel_was_up = FALSE
	if(client?.statpanel == "Protean")
		panel_was_up = TRUE

	release_owner()

	transforming = TRUE

	//Drop all our things
	drop_owner_contents()

	//Record where they should go
	var/atom/suit_spot = drop_location()

	//Suit moves onto the player's location
	S.forceMove(suit_spot)

	// So that we don't see the glow mid-transformation 'cause that looks silly
	S.update_icon()

	//Player moves inside of the suit
	src.forceMove(S)

	//Play animation of turning into a SUIT!
	S.icon_state = "to_suit"
	S.visible_message("<b>[src.name]</b>'s body seems to turn to black sand and collapse into itself, only to quickly re-emerge in the shape of a full-body suit!")

	// Wait for the animation please!
	sleep(13) // The # of frames of both animations

	S.update_icon()
	S.myprotean_is_transforming = FALSE
	return
