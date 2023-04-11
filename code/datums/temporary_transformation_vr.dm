/* -------------------------------------------------------------------------- */
/*                                Temporary TF                                */
/* -------------------------------------------------------------------------- */
/datum/temporary_transformation
	var/mob/living/carbon/human/owner // The mob to whom the transformation belongs.

	var/ckey // The ckey of the player to whom this transformation was initially given.

	var/transforming = FALSE // Whether or not the TF is currently in the process of transforming or reverting a transformation.

/datum/temporary_transformation/New(var/mob/living/carbon/human/owner)
	owner = owner
	ckey = owner.ckey

// Has the owner initiate the transformation.
// Returns:
// 		- TRUE if the TF completed as it was supposed to.
// 		- FALSE otherwise.
// Use `force` to bypass deliberate restrictions on whether or not the owner can transform.
/datum/temporary_transformation/proc/enter_form(force=FALSE)
	return TRUE

// Has the owner return to their normal form.
// Returns:
// 		- TRUE if the TF exited as it was supposed to.
// 		- FALSE otherwise.
// Use `force` to bypass deliberate restrictions on whether or not the owner can transform.
/datum/temporary_transformation/proc/exit_form(force=FALSE)
	return TRUE

// Transformations that completely change the person's body generally tend to make them drop items,
// lose clothing, etc.
// That is handled here.
// Returns a list of the items that still remain in the mob's contents.
/datum/temporary_transformation/proc/drop_owner_contents()
	var/list/things_to_drop = owner.contents.Copy()
	var/list/things_to_not_drop = get_contents_drop_whitelist()
	for(var/obj/item/I in things_to_drop) //rip hoarders
		if(I in things_to_not_drop)
			continue
		owner.drop_from_inventory(I)
		things_to_drop -= I

	return things_to_drop

// Returns a list of items that will not be dropped from the owner when drop_owner_contents() is called.
/datum/temporary_transformation/proc/get_contents_drop_whitelist()
	var/mob/living/carbon/human/O = owner
	if (!O)
		log_debug("<span class='danger'>ERROR: Temporary transformation of type '[src.type]' can't find its owner's body (ckey: '[(ckey ? ckey : "{null}")]').</span>")
		return null
	var/list/things_to_not_drop = list()
	things_to_not_drop += O.nif
	things_to_not_drop += O.organs
	things_to_not_drop += O.internal_organs
	return things_to_not_drop

// Transformations may also cause the owner to be released in some way,
// like being unbuckled or letting go of whatever they're holding/pulling.
// That is handled here.
/datum/temporary_transformation/proc/release_owner()
	var/mob/living/carbon/human/O = owner
	if (!O)
		log_debug("<span class='danger'>ERROR: Temporary transformation of type '[src.type]' can't find its owner's body (ckey: '[(ckey ? ckey : "{null}")]').</span>")
		return
	O.handle_grasp() //It's possible to blob out before some key parts of the life loop. This results in things getting dropped at null. TODO: Fix the code so this can be done better.
	O.remove_micros(src, src) //Living things don't fare well in roblobs.
	if(O.buckled)
		O.buckled.unbuckle_mob()
	if(LAZYLEN(O.buckled_mobs))
		for(var/buckledmob in O.buckled_mobs)
			O.riding_datum.force_dismount(buckledmob)
	if(O.pulledby)
		O.pulledby.stop_pulling()
	O.stop_pulling()

// Attempts to find a type of temporary transformation that they are capable of (See `temporary_forms` in mob_defines_vr.dm).
/mob/living/carbon/human/proc/get_temporary_transformation(var/atom/tf_type)
	for (var/datum/temporary_transformation/T in temporary_forms)
		if (T && istype(T, tf_type))
			return T
	return null

/* -------------------------------------------------------------------------- */
/*                        Mob-specific temp. TF Procs                         */
/* -------------------------------------------------------------------------- */

// Attempts to initiate a transformation of the given type, if the mob is capable of it (See `temporary_forms` in mob_defines_vr.dm).
// Returns:
// 		- TRUE if the TF was successful.
// 		- FALSE if either there was no TF in the mob of the given type, or because the TF itself failed.
/mob/living/carbon/human/proc/safe_enter_temporary_transformation(var/atom/tf_type)
	var/datum/temporary_transformation/T = get_temporary_transformation(tf_type)
	if (!T)
		return FALSE
	return T.enter_form()

// Attempts to exit a transformation of the given type, if the mob is capable of it (See `temporary_forms` in mob_defines_vr.dm).
// Returns:
// 		- TRUE if the TF was successfully reversed.
// 		- FALSE if either there was no TF in the mob of the given type, or because the TF itself failed.
/mob/living/carbon/human/proc/safe_exit_temporary_transformation(var/atom/tf_type)
	var/datum/temporary_transformation/T = get_temporary_transformation(tf_type)
	if (!T)
		return FALSE
	return T.exit_form()
