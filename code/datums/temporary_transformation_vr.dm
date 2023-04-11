/* -------------------------------------------------------------------------- */
/*                                Temporary TF                                */
/* -------------------------------------------------------------------------- */
/datum/temporary_transformation
	var/mob/living/carbon/human/tf_owner // The mob to whom the transformation belongs.

	var/ckey // The ckey of the player to whom this transformation was initially given.

/datum/temporary_transformation/New(var/mob/living/carbon/human/owner)
	tf_owner = owner
	ckey = tf_owner.ckey

// Has the target mob initiate the transformation.
// Returns true if the TF did as it was supposed to, false otherwise.
// Use `force` to bypass deliberate restrictions on whether or not the owner can transform.
/datum/temporary_transformation/proc/enter_form(force=FALSE)
		return TRUE

// Has the target mob return to their normal form.
// Returns true if the TF did as it was supposed to, false otherwise.
// Use `force` to bypass deliberate restrictions on whether or not the owner can transform.
/datum/temporary_transformation/proc/exit_form(force=FALSE)
		return TRUE

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
