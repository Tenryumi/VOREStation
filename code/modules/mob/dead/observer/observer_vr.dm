/mob/observer/dead/verb/nifjoin()
	set category = "Ghost.Join"
	set name = "Join Into Soulcatcher"
	set desc = "Select a player with a working NIF + Soulcatcher NIFSoft to join into it."

	var/picked = tgui_input_list(src, "Pick a friend with NIF and Soulcatcher to join into. Harrass strangers, get banned. Not everyone has a NIF w/ Soulcatcher.","Select a player", player_list)

	//Didn't pick anyone or picked a null
	if(!picked)
		return

	//Good choice testing and some instance-grabbing
	if(!ishuman(picked))
		to_chat(src,span_warning("[picked] isn't in a humanoid mob at the moment."))
		return

	var/mob/living/carbon/human/H = picked

	if(H.stat || !H.client)
		to_chat(src,span_warning("[H] isn't awake/alive at the moment."))
		return

	if(!H.nif)
		to_chat(src,span_warning("[H] doesn't have a NIF installed."))
		return

	var/datum/nifsoft/soulcatcher/SC = H.nif.imp_check(NIF_SOULCATCHER)
	if(!SC)
		to_chat(src,span_warning("[H] doesn't have the Soulcatcher NIFSoft installed, or their NIF is unpowered."))
		return

	//Fine fine, we can ask.
	var/obj/item/nif/nif = H.nif
	to_chat(src,span_notice("Request sent to [H]."))

	var/req_time = world.time
	nif.notify("Transient mindstate detected, analyzing...")
	sleep(15) //So if they are typing they get interrupted by sound and message, and don't type over the box
	var/response = tgui_alert(H,"[src] ([src.key]) wants to join into your Soulcatcher.","Soulcatcher Request",list("Deny","Allow"), timeout = 1 MINUTE)

	if(!response || response == "Deny")
		to_chat(src,span_warning("[H] denied your request."))
		return

	if((world.time - req_time) > 1 MINUTE)
		to_chat(H,span_warning("The request had already expired. (1 minute waiting max)"))
		return

	//Final check since we waited for input a couple times.
	if(H && src && src.key && !H.stat && nif && SC)
		if(!mind) //No mind yet, aka haven't played in this round.
			mind = new(key)

		mind.name = name
		mind.current = src
		mind.active = TRUE

		SC.catch_mob(src) //This will result in us being deleted so...

/mob/observer/dead/verb/backup_ping()
	set category = "Ghost.Join"
	set name = "Notify Transcore"
	set desc = "If your past-due backup notification was missed or ignored, you can use this to send a new one."

	if(!mind)
		to_chat(src,span_warning("Your ghost is missing game values that allow this functionality, sorry."))
		return
	var/datum/transcore_db/db = SStranscore.db_by_mind_name(mind.name)
	if(db)
		var/datum/transhuman/mind_record/record = db.backed_up[src.mind.name]
		if(!(record.dead_state == MR_DEAD))
			if((world.time - timeofdeath ) > 5 MINUTES)	//Allows notify transcore to be used if you have an entry but for some reason weren't marked as dead
				record.dead_state = MR_DEAD				//Such as if you got scanned but didn't take an implant. It's a little funky, but I mean, you got scanned
				db.notify(record)						//So you probably will want to let someone know if you die.
				record.last_notification = world.time
				to_chat(src, span_notice("New notification has been sent."))
			else
				to_chat(src, span_warning("Your backup is not past-due yet."))
		else if((world.time - record.last_notification) < 5 MINUTES)
			to_chat(src, span_warning("Too little time has passed since your last notification."))
		else
			db.notify(record)
			record.last_notification = world.time
			to_chat(src, span_notice("New notification has been sent."))
	else
		to_chat(src,span_warning("No backup record could be found, sorry."))
/*
/mob/observer/dead/verb/backup_delay()
	set category = "Ghost.Settings"
	set name = "Cancel Transcore Notification"
	set desc = "You can use this to avoid automatic backup notification happening. Manual notification can still be used."

	if(!mind)
		to_chat(src,span_warning("Your ghost is missing game values that allow this functionality, sorry."))
		return
	var/datum/transcore_db/db = SStranscore.db_by_mind_name(mind.name)
	if(db)
		var/datum/transhuman/mind_record/record = db.backed_up[src.mind.name]
		if(record.dead_state == MR_DEAD || !(record.do_notify))
			to_chat(src, span_warning("The notification has already happened or been delayed."))
		else
			record.do_notify = FALSE
			to_chat(src, span_notice("Overdue mind backup notification delayed successfully."))
	else
		to_chat(src,span_warning("No backup record could be found, sorry."))
*/
/mob/observer/dead/verb/findghostpod() //Moves the ghost instead of just changing the ghosts's eye -Nodrak
	set category = "Ghost.Join"
	set name = "Find Ghost Pod"
	set desc = "Find an active ghost pod"
	set popup_menu = FALSE

	if(!isobserver(src)) //Make sure they're an observer!
		return

	var/input = tgui_input_list(src, "Select a ghost pod:", "Ghost Jump", observe_list_format(GLOB.active_ghost_pods))
	if(!input)
		to_chat(src, span_filter_notice("No active ghost pods detected."))
		return

	var/target = observe_list_format(GLOB.active_ghost_pods)[input]
	if (!target)//Make sure we actually have a target
		return
	else
		var/obj/O = target //Destination mob
		var/turf/T = get_turf(O) //Turf of the destination mob

		if(T && isturf(T))	//Make sure the turf exists, then move the source to that destination.
			forceMove(T)
			stop_following()
		else
			to_chat(src, span_filter_notice("This ghost pod is not located in the game world."))

/mob/observer/dead/verb/findautoresleever()
	set category = "Ghost.Join"
	set name = "Find Auto Resleever"
	set desc = "Find a Auto Resleever"
	set popup_menu = FALSE

	if(!isobserver(src)) //Make sure they're an observer!
		return

	var/list/ar = list()
	for(var/obj/machinery/transhuman/autoresleever/A in world)
		if(A.spawntype)
			continue
		else
			ar |= A

	var/obj/machinery/transhuman/autoresleever/thisone = pick(ar)

	if(!thisone)
		to_chat(src, span_warning("There appears to be no auto-resleevers available."))
		return
	var/L = get_turf(thisone)
	if(!L)
		to_chat(src, span_warning("There appears to be something wrong with this auto-resleever, try again."))
		return

	forceMove(L)
