#define RESTART_COUNTER_PATH "data/round_counter.txt"

GLOBAL_VAR(restart_counter)

#define RECOMMENDED_VERSION 513
/world/New()
	world_startup_time = world.timeofday
	rollover_safety_date = world.realtime - world.timeofday // 00:00 today (ish, since floating point error with world.realtime) of today
	to_world_log("Map Loading Complete")
	//logs
	//VOREStation Edit Start
	GLOB.log_directory += time2text(world.realtime, "YYYY/MM-Month/DD-Day/round-hh-mm-ss")
	GLOB.diary = start_log("[GLOB.log_directory].log")
	GLOB.href_logfile = start_log("[GLOB.log_directory]-hrefs.htm")
	GLOB.error_log = start_log("[GLOB.log_directory]-error.log")
	GLOB.sql_error_log = start_log("[GLOB.log_directory]-sql-error.log")
	GLOB.query_debug_log = start_log("[GLOB.log_directory]-query-debug.log")
	GLOB.debug_log = start_log("[GLOB.log_directory]-debug.log")
	//VOREStation Edit End

	var/latest_changelog = file("[global.config.directory]/../html/changelogs/archive/" + time2text(world.timeofday, "YYYY-MM") + ".yml")
	GLOB.changelog_hash = fexists(latest_changelog) ? md5(latest_changelog) : "" //for telling if the changelog has changed recently
	to_world_log("Changelog Hash: '[GLOB.changelog_hash]' ([latest_changelog])")

	if(byond_version < RECOMMENDED_VERSION)
		to_world_log("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	InitTgs()

	config.Load(params[OVERRIDE_CONFIG_DIRECTORY_PARAMETER])

	load_admins()

	ConfigLoaded()
	makeDatumRefLists()

	var servername = CONFIG_GET(string/servername)
	if(config && servername != null && CONFIG_GET(flag/server_suffix) && world.port > 0)
		// dumb and hardcoded but I don't care~
		servername += " #[(world.port % 1000) / 100]"
		CONFIG_SET(string/servername, servername)

	// TODO - Figure out what this is. Can you assign to world.log?
	// if(config && CONFIG_FLAG(flag/log_runtime))
	// 	log = file("data/logs/runtime/[time2text(world.realtime,"YYYY-MM-DD-(hh-mm-ss)")]-runtime.log")

	GLOB.timezoneOffset = get_timezone_offset()

	callHook("startup")
	//Emergency Fix
	load_mods()
	//end-emergency fix

	src.update_status()
	setup_season()	//VOREStation Addition

	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (debug_server)
		call_ext(debug_server, "auxtools_init")()
		enable_debugging()

	. = ..()

#ifdef UNIT_TEST
	log_unit_test("Unit Tests Enabled.  This will destroy the world when testing is complete.")
	log_unit_test("If you did not intend to enable this please check code/__defines/unit_testing.dm")
#endif

	// This is kinda important. Set up details of what the hell things are made of.
	populate_material_list()

	// Create frame types.
	populate_frame_types()

	// Create floor types.
	populate_flooring_types()

	// Create robolimbs for chargen.
	populate_robolimb_list()

	master_controller = new /datum/controller/game_controller()
	Master.Initialize(10, FALSE, TRUE) // VOREStation Edit

	spawn(1)
		master_controller.setup()
#ifdef UNIT_TEST
		initialize_unit_tests()
#endif

	spawn(3000)		//so we aren't adding to the round-start lag
		if(CONFIG_GET(flag/ToRban))
			ToRban_autoupdate()

#undef RECOMMENDED_VERSION

	return

/// Initializes TGS and loads the returned revising info into GLOB.revdata
/world/proc/InitTgs()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	GLOB.revdata.load_tgs_info()

/// Runs after config is loaded but before Master is initialized
/world/proc/ConfigLoaded()
	// Everything in here is prioritized in a very specific way.
	// If you need to add to it, ask yourself hard if what your adding is in the right spot
	// (i.e. basically nothing should be added before load_admins() in here)

	// Try to set round ID
	SSdbcore.InitializeRound()

	//apply a default value to config.python_path, if needed
	if (!CONFIG_GET(string/python_path))
		if(world.system_type == UNIX)
			CONFIG_SET(string/python_path, "/usr/bin/env python2")
		else //probably windows, if not this should work anyway
			CONFIG_SET(string/python_path, "python")

	if(fexists(RESTART_COUNTER_PATH))
		GLOB.restart_counter = text2num(trim(file2text(RESTART_COUNTER_PATH)))
		fdel(RESTART_COUNTER_PATH)

var/world_topic_spam_protect_ip = "0.0.0.0"
var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	TGS_TOPIC
	log_topic("\"[T]\", from:[addr], master:[master], key:[key]")

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "players")
		var/n = 0
		for(var/mob/M in player_list)
			if(M.client)
				n++
		return n

	else if (copytext(T,1,7) == "status")
		var/input[] = params2list(T)
		var/list/s = list()
		s["version"] = GLOB.game_version
		s["mode"] = GLOB.master_mode
		s["respawn"] = CONFIG_GET(flag/abandon_allowed)
		s["persistance"] = CONFIG_GET(flag/persistence_disabled)
		s["enter"] = CONFIG_GET(flag/enter_allowed)
		s["vote"] = CONFIG_GET(flag/allow_vote_mode)
		s["ai"] = CONFIG_GET(flag/allow_ai)
		s["host"] = host ? host : null

		// This is dumb, but spacestation13.com's banners break if player count isn't the 8th field of the reply, so... this has to go here.
		s["players"] = 0
		s["stationtime"] = stationtime2text()
		s["roundduration"] = roundduration2text()
		s["map"] = strip_improper(using_map.full_name) //Done to remove the non-UTF-8 text macros

		if(input["status"] == "2") // Shiny new hip status.
			var/active = 0
			var/list/players = list()
			var/list/admins = list()

			for(var/client/C in GLOB.clients)
				if(C.holder)
					if(C.holder.fakekey)
						continue
					admins[C.key] = C.holder.rank_names()
				players += C.key
				if(isliving(C.mob))
					active++

			s["players"] = players.len
			//s["playerlist"] = list2params(players)
			s["active_players"] = active
			var/list/adm = get_admin_counts()
			var/list/presentmins = adm["present"]
			var/list/afkmins = adm["afk"]
			s["admins"] = presentmins.len + afkmins.len //equivalent to the info gotten from adminwho
			//s["adminlist"] = list2params(admins)
		else // Legacy.
			var/n = 0
			var/admins = 0

			for(var/client/C in GLOB.clients)
				if(C.holder)
					if(C.holder.fakekey)
						continue	//so stealthmins aren't revealed by the hub
					admins++
				s["player[n]"] = C.key
				n++

			s["players"] = n
			s["admins"] = admins

		return list2params(s)

	else if(T == "manifest")
		var/list/positions = list()
		var/list/set_names = list(
				"heads" = SSjob.get_job_titles_in_department(DEPARTMENT_COMMAND),
				"sec" = SSjob.get_job_titles_in_department(DEPARTMENT_SECURITY),
				"eng" = SSjob.get_job_titles_in_department(DEPARTMENT_ENGINEERING),
				"med" = SSjob.get_job_titles_in_department(DEPARTMENT_MEDICAL),
				"sci" = SSjob.get_job_titles_in_department(DEPARTMENT_RESEARCH),
				"car" = SSjob.get_job_titles_in_department(DEPARTMENT_CARGO),
				"pla" = SSjob.get_job_titles_in_department(DEPARTMENT_PLANET), //VOREStation Add,
				"civ" = SSjob.get_job_titles_in_department(DEPARTMENT_CIVILIAN),
				"bot" = SSjob.get_job_titles_in_department(DEPARTMENT_SYNTHETIC)
			)

		for(var/datum/data/record/t in GLOB.data_core.general)
			var/name = t.fields["name"]
			var/rank = t.fields["rank"]
			var/real_rank = make_list_rank(t.fields["real_rank"])

			var/department = 0
			for(var/k in set_names)
				if(real_rank in set_names[k])
					if(!positions[k])
						positions[k] = list()
					positions[k][name] = rank
					department = 1
			if(!department)
				if(!positions["misc"])
					positions["misc"] = list()
				positions["misc"][name] = rank

		for(var/datum/data/record/t in GLOB.data_core.hidden_general)
			var/name = t.fields["name"]
			var/rank = t.fields["rank"]
			var/real_rank = make_list_rank(t.fields["real_rank"])

			var/datum/job/J = SSjob.get_job(real_rank)
			if(J?.offmap_spawn)
				if(!positions["off"])
					positions["off"] = list()
				positions["off"][name] = rank

		// Synthetics don't have actual records, so we will pull them from here.
		for(var/mob/living/silicon/ai/ai in mob_list)
			if(!positions["bot"])
				positions["bot"] = list()
			positions["bot"][ai.name] = "Artificial Intelligence"
		for(var/mob/living/silicon/robot/robot in mob_list)
			// No combat/syndicate cyborgs, no drones, and no AI shells.
			if(robot.shell)
				continue
			if(robot.module && robot.module.hide_on_manifest())
				continue
			if(!positions["bot"])
				positions["bot"] = list()
			positions["bot"][robot.name] = "[robot.modtype] [robot.braintype]"

		for(var/k in positions)
			positions[k] = list2params(positions[k]) // converts positions["heads"] = list("Bob"="Captain", "Bill"="CMO") into positions["heads"] = "Bob=Captain&Bill=CMO"

		return list2params(positions)

	else if(T == "revision")
		if(GLOB.revdata.commit)
			return list2params(list(testmerge = GLOB.revdata.testmerge, date = GLOB.revdata.date, commit = GLOB.revdata.commit, originmastercommit = GLOB.revdata.originmastercommit))
		else
			return "unknown"

	else if(copytext(T,1,9) == "adminmsg")
		/*
			We got an adminmsg from IRC bot lets split the input then validate the input.
			expected output:
				1. adminmsg = ckey of person the message is to
				2. msg = contents of message, parems2list requires
				3. validatationkey = the key the bot has, it should match the gameservers commspassword in it's configuration.
				4. sender = the ircnick that send the message.
		*/


		var/input[] = params2list(T)
		var/password = CONFIG_GET(string/comms_password)
		if(!password || input["key"] != password)
			if(world_topic_spam_protect_ip == addr && abs(world_topic_spam_protect_time - world.time) < 50)

				spawn(50)
					world_topic_spam_protect_time = world.time
					return

			world_topic_spam_protect_time = world.time
			world_topic_spam_protect_ip = addr

			return "Bad Key"

		var/client/C
		var/req_ckey = ckey(input["adminmsg"])

		for(var/client/K in GLOB.clients)
			if(K.ckey == req_ckey)
				C = K
				break
		if(!C)
			return "No client with that name on server"

		var/rank = input["rank"]
		if(!rank)
			rank = "Admin"

		var/message =	span_red("IRC-[rank] PM from <b><a href='byond://?irc_msg=[input["sender"]]'>IRC-[input["sender"]]</a></b>: [input["msg"]]")
		var/amessage =  span_blue("IRC-[rank] PM from <a href='byond://?irc_msg=[input["sender"]]'>IRC-[input["sender"]]</a> to <b>[key_name(C)]</b> : [input["msg"]]")

		C.received_irc_pm = world.time
		C.irc_admin = input["sender"]

		C << 'sound/effects/adminhelp.ogg'
		to_chat(C,message)


		for(var/client/A in GLOB.admins)
			if(A != C)
				to_chat(A,amessage)

		return "Message Successful"

/// Returns TRUE if the world should do a TGS hard reboot.
/world/proc/check_hard_reboot()
	if(!TgsAvailable())
		return FALSE
	// byond-tracy can't clean up itself, and thus we should always hard reboot if its enabled, to avoid an infinitely growing trace.
	//if(Tracy?.enabled)
	//	return TRUE
	var/ruhr = CONFIG_GET(number/rounds_until_hard_restart)
	switch(ruhr)
		if(-1)
			return FALSE
		if(0)
			return TRUE
		else
			if(GLOB.restart_counter >= ruhr)
				return TRUE
			else
				text2file("[++GLOB.restart_counter]", RESTART_COUNTER_PATH)
				return FALSE

/world/Reboot(reason = 0, fast_track = FALSE)
	/*spawn(0)
		world << sound(pick('sound/AI/newroundsexy.ogg','sound/misc/apcdestroyed.ogg','sound/misc/bangindonk.ogg')) // random end sounds!! - LastyBatsy
		*/

	if (reason || fast_track) //special reboot, do none of the normal stuff
		if (usr)
			log_admin("[key_name(usr)] Has requested an immediate world restart via client side debugging tools")
			message_admins("[key_name_admin(usr)] Has requested an immediate world restart via client side debugging tools")
			to_world(span_boldannounce("[key_name_admin(usr)] has requested an immediate world restart via client side debugging tools"))

		else
			to_world(span_boldannounce("Rebooting world immediately due to host request"))
	else
		Master.Shutdown()	//run SS shutdowns
		for(var/client/C in GLOB.clients)
			if(CONFIG_GET(string/server))	//if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
				C << link("byond://[CONFIG_GET(string/server)]")

	if(check_hard_reboot())
		log_world("World hard rebooted at [time_stamp()]")
		//shutdown_logging() // See comment below.
		//QDEL_NULL(Tracy)
		//QDEL_NULL(Debugger)
		TgsEndProcess()
		return ..()

	TgsReboot()
	log_world("World rebooted at [time_stamp()]")
	..()

/hook/startup/proc/loadMode()
	world.load_mode()
	return 1

/world/proc/load_mode()
	if(!fexists("data/mode.txt"))
		return


	var/list/Lines = file2list("data/mode.txt")
	if(Lines.len)
		if(Lines[1])
			GLOB.master_mode = Lines[1]
			log_misc("Saved mode is '[GLOB.master_mode]'")

/world/proc/save_mode(var/the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	F << the_mode

/hook/startup/proc/loadMods()
	world.load_mods()
	return 1

/world/proc/load_mods()
	if(CONFIG_GET(flag/admin_legacy_system))
		var/text = file2text("config/moderators.txt")
		if (!text)
			error("Failed to load config/mods.txt")
		else
			var/list/lines = splittext(text, "\n")
			for(var/line in lines)
				if (!line)
					continue

				if (copytext(line, 1, 2) == ";")
					continue

				var/title = "Moderator"
				var/rights = GLOB.admin_ranks[title]

				var/ckey = copytext(line, 1, length(line)+1)
				var/datum/admins/D = new /datum/admins(title, rights, ckey)
				D.associate(GLOB.directory[ckey])

/world/proc/update_status()
	var/s = ""

	if (config && CONFIG_GET(string/servername))
		s += span_bold("[CONFIG_GET(string/servername)]") + " &#8212; "

	s += span_bold("[station_name()]");
	s += " ("
	s += "<a href=\"https://\">" //Change this to wherever you want the hub to link to.
//	s += "[GLOB.game_version]"
	s += "Default"  //Replace this with something else. Or ever better, delete it and uncomment the game version.
	s += "</a>"
	s += ")"

	var/list/features = list()

	if(ticker)
		if(GLOB.master_mode)
			features += GLOB.master_mode
	else
		features += span_bold("STARTING")

	if (!CONFIG_GET(flag/enter_allowed))
		features += "closed"

	features += CONFIG_GET(flag/abandon_allowed) ? "respawn" : "no respawn"

	features += CONFIG_GET(flag/persistence_disabled) ? "persistence disabled" : "persistence enabled"

	features += CONFIG_GET(flag/persistence_ignore_mapload) ? "persistence mapload disabled" : "persistence mapload enabled"

	if (config && CONFIG_GET(flag/allow_vote_mode))
		features += "vote"

	if (config && CONFIG_GET(flag/allow_ai))
		features += "AI allowed"

	var/n = 0
	for (var/mob/M in player_list)
		if (M.client)
			n++

	if (n > 1)
		features += "~[n] players"
	else if (n > 0)
		features += "~[n] player"


	if (config && CONFIG_GET(string/hostedby))
		features += "hosted by <b>[CONFIG_GET(string/hostedby)]</b>"

	if (features)
		s += ": [jointext(features, ", ")]"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0
var/failed_old_db_connections = 0

/hook/startup/proc/connectDB()
	if(!CONFIG_GET(flag/sql_enabled))
		to_world_log("SQL connection disabled in config.")
	else if(!setup_database_connection())
		to_world_log("Your server failed to establish a connection with the feedback database.")
	else
		to_world_log("Feedback database connection established.")
	return 1

/proc/setup_database_connection()
	if(!CONFIG_GET(flag/sql_enabled))
		return 0
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0

	if(!SSdbcore)
		SSdbcore = new()

	var/user = CONFIG_GET(string/feedback_login)
	var/pass = CONFIG_GET(string/feedback_password)
	var/db = CONFIG_GET(string/feedback_database)
	var/address = CONFIG_GET(string/address)
	var/port = CONFIG_GET(number/port)

	SSdbcore.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = SSdbcore.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		to_world_log(SSdbcore.ErrorMsg())

	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
/proc/establish_db_connection()
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!SSdbcore || !SSdbcore.IsConnected())
		return setup_database_connection()
	else
		return 1

// Cleans up DB connections and recreates them
/proc/reset_database_connections()
	var/list/results = list("-- Resetting DB connections --")
	failed_db_connections = 0

	if(SSdbcore?.IsConnected())
		SSdbcore.Disconnect()
		results += "SSdbcore was connected and asked to disconnect"
	else
		results += "SSdbcore was not connected"

	if(!CONFIG_GET(flag/sql_enabled))
		results += "stopping because config.sql_enabled = false"
	else
		. = setup_database_connection()
		if(.)
			results += "SUCCESS: set up a connection successfully with setup_database_connection()"
		else
			results += "FAIL: failed to connect to the database with setup_database_connection()"

	results += "-- DB Reset End --"
	to_world_log(results.Join("\n"))

// Things to do when a new z-level was just made.
/world/proc/max_z_changed()
	if(!istype(GLOB.players_by_zlevel, /list))
		GLOB.players_by_zlevel = new /list(world.maxz, 0)
		GLOB.living_players_by_zlevel = new /list(world.maxz, 0)

	while(GLOB.players_by_zlevel.len < world.maxz)
		GLOB.players_by_zlevel.len++
		GLOB.players_by_zlevel[GLOB.players_by_zlevel.len] = list()

		GLOB.living_players_by_zlevel.len++
		GLOB.living_players_by_zlevel[GLOB.living_players_by_zlevel.len] = list()

// Call this to make a new blank z-level, don't modify maxz directly.
/world/proc/increment_max_z()
	maxz++
	max_z_changed()

// Call this to change world.fps, don't modify it directly.
/world/proc/change_fps(new_value = 20)
	if(new_value <= 0)
		CRASH("change_fps() called with [new_value] new_value.")
	if(fps == new_value)
		return //No change required.

	fps = new_value
	on_tickrate_change()

// Called whenver world.tick_lag or world.fps are changed.
/world/proc/on_tickrate_change()
	SStimer?.reset_buckets()

#undef FAILED_DB_CONNECTION_CUTOFF

/proc/get_world_url()
	. = "byond://"
	if(CONFIG_GET(string/serverurl))
		. += CONFIG_GET(string/serverurl)
	else if(CONFIG_GET(string/server))
		. += CONFIG_GET(string/server)
	else
		. += "[world.address]:[world.port]"

/proc/auxtools_stack_trace(msg)
	CRASH(msg)

/proc/auxtools_expr_stub()
	CRASH("auxtools not loaded")

/proc/enable_debugging(mode, port)
	CRASH("auxtools not loaded")

/world/Del()
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (debug_server)
		call_ext(debug_server, "auxtools_shutdown")()
	. = ..()

#undef RESTART_COUNTER_PATH
