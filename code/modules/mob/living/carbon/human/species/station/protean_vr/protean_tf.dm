/datum/temporary_transformation/protean
	abstract_type = TRUE

/datum/temporary_transformation/protean/release_owner()
	. = ..()
	var/mob/living/carbon/human/O = owner
	O.handle_grasp() //It's possible to blob out before some key parts of the life loop. This results in things getting dropped at null. TODO: Fix the code so this can be done better.
	remove_micros(src, src) //Living things don't fare well in roblobs.
	if(O.buckled)
		O.buckled.unbuckle_mob()
	if(LAZYLEN(O.buckled_mobs))
		for(var/buckledmob in O.buckled_mobs)
			O.riding_datum.force_dismount(buckledmob)
	if(O.pulledby)
		O.pulledby.stop_pulling()
	O.stop_pulling()

/datum/temporary_transformation/protean/get_contents_drop_whitelist()
	var/list/things_to_not_drop = ..()

	for(var/obj/item/I in owner.contents.Copy()) //rip hoarders
		if(I.protean_drop_whitelist)
			things_to_not_drop += I

	return things_to_not_drop

/datum/temporary_transformation/protean/drop_owner_contents()
	var/list/things_to_drop = ..()
	var/mob/living/carbon/human/O = owner
	if(O.w_uniform && istype(O.w_uniform,/obj/item/clothing)) //No webbings tho. We do this after in case a suit was in the way
		var/obj/item/clothing/uniform = O.w_uniform
		if(LAZYLEN(uniform.accessories))
			for(var/obj/item/clothing/accessory/A in uniform.accessories)
				if(is_type_in_list(A, disallowed_protean_accessories))
					uniform.remove_accessory(null,A) //First param is user, but adds fingerprints and messages
