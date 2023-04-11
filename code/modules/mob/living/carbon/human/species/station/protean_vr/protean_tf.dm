/datum/temporary_transformation/protean/

/datum/temporary_transformation/protean/release_owner()
	. = ..()
	handle_grasp() //It's possible to blob out before some key parts of the life loop. This results in things getting dropped at null. TODO: Fix the code so this can be done better.
	remove_micros(src, src) //Living things don't fare well in roblobs.
	if(owner.buckled)
		buckled.unbuckle_mob()
	if(LAZYLEN(buckled_mobs))
		for(var/buckledmob in buckled_mobs)
			riding_datum.force_dismount(buckledmob)
	if(pulledby)
		pulledby.stop_pulling()
	stop_pulling()

/datum/temporary_transformation/protean/get_contents_drop_whitelist()
	var/list/things_to_not_drop = ..()

	for(var/obj/item/I in things_to_drop) //rip hoarders
		if(I.protean_drop_whitelist)
			things_to_not_drop += I

/datum/temporary_transformation/protean/drop_owner_contents()
	var/list/things_to_drop = ..()
	if(w_uniform && istype(w_uniform,/obj/item/clothing)) //No webbings tho. We do this after in case a suit was in the way
		var/obj/item/clothing/uniform = w_uniform
		if(LAZYLEN(uniform.accessories))
			for(var/obj/item/clothing/accessory/A in uniform.accessories)
				if(is_type_in_list(A, disallowed_protean_accessories))
					uniform.remove_accessory(null,A) //First param is user, but adds fingerprints and messages
