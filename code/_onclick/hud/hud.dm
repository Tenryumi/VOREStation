#define MAX_AMMO_HUD_POSSIBLE 4 // Cap the amount of HUDs at 4.
/*
	The global hud:
	Uses the same visual objects for all players.
*/
GLOBAL_DATUM_INIT(global_hud, /datum/global_hud, new)
GLOBAL_LIST_INIT(global_huds, list(
		GLOB.global_hud.druggy,
		GLOB.global_hud.blurry,
		GLOB.global_hud.whitense,
		GLOB.global_hud.vimpaired,
		GLOB.global_hud.darkMask,
		GLOB.global_hud.centermarker,
		GLOB.global_hud.nvg,
		GLOB.global_hud.thermal,
		GLOB.global_hud.meson,
		GLOB.global_hud.science,
		GLOB.global_hud.material,
		GLOB.global_hud.holomap
))

/datum/hud/var/obj/screen/grab_intent
/datum/hud/var/obj/screen/hurt_intent
/datum/hud/var/obj/screen/disarm_intent
/datum/hud/var/obj/screen/help_intent

/datum/global_hud
	var/obj/screen/druggy
	var/obj/screen/blurry
	var/obj/screen/whitense
	var/list/vimpaired
	var/list/darkMask
	var/obj/screen/centermarker
	var/obj/screen/darksight
	var/obj/screen/nvg
	var/obj/screen/thermal
	var/obj/screen/meson
	var/obj/screen/science
	var/obj/screen/material
	var/obj/screen/holomap

/datum/global_hud/proc/setup_overlay(var/icon_state)
	var/obj/screen/screen = new /obj/screen()
	screen.alpha = 30 // Adjut this if you want goggle overlays to be thinner or thicker. //VOREStation Edit
	screen.screen_loc = "SOUTHWEST to NORTHEAST" // Will tile up to the whole screen, scaling beyond 15x15 if needed.
	screen.icon = 'icons/obj/hud_tiled_vr.dmi'	//VOREStation Edit
	screen.icon_state = icon_state
	screen.layer = SCREEN_LAYER
	screen.plane = PLANE_FULLSCREEN
	screen.mouse_opacity = 0

	return screen

/obj/screen/global_screen
	screen_loc = ui_entire_screen
	plane = PLANE_FULLSCREEN
	mouse_opacity = 0

/datum/global_hud/New()
	//420erryday psychedellic colours screen overlay for when you are high
	druggy = new /obj/screen/global_screen()
	druggy.icon_state = "druggy"

	//that white blurry effect you get when you eyes are damaged
	blurry = new /obj/screen/global_screen()
	blurry.icon_state = "blurry"

	//static overlay effect for cameras and the like
	whitense = new /obj/screen/global_screen()
	whitense.icon = 'icons/effects/static.dmi'
	whitense.icon_state = "1 light"

	//darksight 'hanger' for attached icons
	darksight = new /obj/screen()
	darksight.icon = null
	darksight.screen_loc = "1,1"
	darksight.plane = PLANE_LIGHTING

	//Marks the center of the screen, for things like ventcrawl
	centermarker = new /obj/screen()
	centermarker.icon = 'icons/mob/screen1.dmi'
	centermarker.icon_state = "centermarker"
	centermarker.screen_loc = "CENTER,CENTER"

	//Marks the center of the screen, for things like ventcrawl
	centermarker = new /obj/screen()
	centermarker.icon = 'icons/mob/screen1.dmi'
	centermarker.icon_state = "centermarker"
	centermarker.screen_loc = "CENTER,CENTER"

	nvg = setup_overlay("nvg_hud")
	thermal = setup_overlay("thermal_hud")
	meson = setup_overlay("meson_hud")
	science = setup_overlay("science_hud")
	material = setup_overlay("material_hud")

	holomap = new /obj/screen()
	holomap.name = "holomap"
	holomap.icon = null
	holomap.screen_loc = ui_holomap
	holomap.mouse_opacity = 0

	var/obj/screen/O
	var/i
	//that nasty looking dither you  get when you're short-sighted
	vimpaired = newlist(/obj/screen,/obj/screen,/obj/screen,/obj/screen)
	O = vimpaired[1]
	O.screen_loc = "1,1 to 5,15"
	O.plane = PLANE_FULLSCREEN
	O = vimpaired[2]
	O.screen_loc = "5,1 to 10,5"
	O.plane = PLANE_FULLSCREEN
	O = vimpaired[3]
	O.screen_loc = "6,11 to 10,15"
	O.plane = PLANE_FULLSCREEN
	O = vimpaired[4]
	O.screen_loc = "11,1 to 15,15"
	O.plane = PLANE_FULLSCREEN

	//welding mask overlay black/dither
	darkMask = newlist(/obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen, /obj/screen)
	O = darkMask[1]
	O.screen_loc = "WEST+2,SOUTH+2 to WEST+4,NORTH-2"
	O = darkMask[2]
	O.screen_loc = "WEST+4,SOUTH+2 to EAST-5,SOUTH+4"
	O = darkMask[3]
	O.screen_loc = "WEST+5,NORTH-4 to EAST-5,NORTH-2"
	O = darkMask[4]
	O.screen_loc = "EAST-4,SOUTH+2 to EAST-2,NORTH-2"
	O = darkMask[5]
	O.screen_loc = "WEST,SOUTH to EAST,SOUTH+1"
	O = darkMask[6]
	O.screen_loc = "WEST,SOUTH+2 to WEST+1,NORTH"
	O = darkMask[7]
	O.screen_loc = "EAST-1,SOUTH+2 to EAST,NORTH"
	O = darkMask[8]
	O.screen_loc = "WEST+2,NORTH-1 to EAST-2,NORTH"

	for(i = 1, i <= 4, i++)
		O = vimpaired[i]
		O.icon_state = "dither50"
		O.plane = PLANE_FULLSCREEN
		O.mouse_opacity = 0

		O = darkMask[i]
		O.icon_state = "dither50"
		O.plane = PLANE_FULLSCREEN
		O.mouse_opacity = 0

	for(i = 5, i <= 8, i++)
		O = darkMask[i]
		O.icon_state = "black"
		O.plane = PLANE_FULLSCREEN
		O.mouse_opacity = 2

/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = 1			//Used for the HUD toggle (F12)
	var/inventory_shown = 1		//the inventory
	var/show_intent_icons = 0
	var/hotkey_ui_hidden = 0	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/obj/screen/lingchemdisplay
	var/obj/screen/wiz_instability_display
	var/obj/screen/wiz_energy_display
	var/obj/screen/blobpwrdisplay
	var/obj/screen/blobhealthdisplay
	var/obj/screen/r_hand_hud_object
	var/obj/screen/l_hand_hud_object
	var/obj/screen/action_intent
	var/obj/screen/move_intent
	var/obj/screen/control_vtec

	var/list/adding
	/// Misc hud elements that are hidden when the hud is minimized
	var/list/other
	/// Same, but always shown even when the hud is minimized
	var/list/other_important
	var/list/miniobjs
	var/list/obj/screen/hotkeybuttons

	var/obj/screen/button_palette/toggle_palette
	var/obj/screen/palette_scroll/down/palette_down
	var/obj/screen/palette_scroll/up/palette_up

	var/datum/action_group/palette/palette_actions
	var/datum/action_group/listed/listed_actions
	var/list/floating_actions


	var/list/slot_info

	var/icon/ui_style
	var/ui_color
	var/ui_alpha

	// TGMC Ammo HUD Port
	var/list/obj/screen/ammo_hud_list = list()

	var/list/minihuds = list()

/datum/hud/New(mob/owner)
	mymob = owner
	instantiate()
	..()

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	QDEL_NULL_LIST(minihuds)

	// Actions
	QDEL_NULL(toggle_palette)
	QDEL_NULL(palette_down)
	QDEL_NULL(palette_up)
	QDEL_NULL(palette_actions)
	QDEL_NULL(listed_actions)
	QDEL_LIST(floating_actions)

	grab_intent = null
	hurt_intent = null
	disarm_intent = null
	help_intent = null
	lingchemdisplay = null
	wiz_instability_display = null
	wiz_energy_display = null
	blobpwrdisplay = null
	blobhealthdisplay = null
	r_hand_hud_object = null
	l_hand_hud_object = null
	action_intent = null
	move_intent = null
	control_vtec = null
	adding = null
	other = null
	other_important = null
	hotkeybuttons = null
//	item_action_list = null // ?
	for (var/x in ammo_hud_list)
		remove_ammo_hud(mymob, x)
	ammo_hud_list = null
	mymob = null

	return ..()

/datum/hud/proc/hidden_inventory_update()
	if(!mymob) return
	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		for(var/gear_slot in H.species.hud.gear)
			var/list/hud_data = H.species.hud.gear[gear_slot]
			if(inventory_shown && hud_shown)
				switch(hud_data["slot"])
					if(slot_head)
						if(H.head)      H.head.screen_loc =      hud_data["loc"]
					if(slot_shoes)
						if(H.shoes)     H.shoes.screen_loc =     hud_data["loc"]
					if(slot_l_ear)
						if(H.l_ear)     H.l_ear.screen_loc =     hud_data["loc"]
					if(slot_r_ear)
						if(H.r_ear)     H.r_ear.screen_loc =     hud_data["loc"]
					if(slot_gloves)
						if(H.gloves)    H.gloves.screen_loc =    hud_data["loc"]
					if(slot_glasses)
						if(H.glasses)   H.glasses.screen_loc =   hud_data["loc"]
					if(slot_w_uniform)
						if(H.w_uniform) H.w_uniform.screen_loc = hud_data["loc"]
					if(slot_wear_suit)
						if(H.wear_suit) H.wear_suit.screen_loc = hud_data["loc"]
					if(slot_wear_mask)
						if(H.wear_mask) H.wear_mask.screen_loc = hud_data["loc"]
			else
				switch(hud_data["slot"])
					if(slot_head)
						if(H.head)      H.head.screen_loc =      null
					if(slot_shoes)
						if(H.shoes)     H.shoes.screen_loc =     null
					if(slot_l_ear)
						if(H.l_ear)     H.l_ear.screen_loc =     null
					if(slot_r_ear)
						if(H.r_ear)     H.r_ear.screen_loc =     null
					if(slot_gloves)
						if(H.gloves)    H.gloves.screen_loc =    null
					if(slot_glasses)
						if(H.glasses)   H.glasses.screen_loc =   null
					if(slot_w_uniform)
						if(H.w_uniform) H.w_uniform.screen_loc = null
					if(slot_wear_suit)
						if(H.wear_suit) H.wear_suit.screen_loc = null
					if(slot_wear_mask)
						if(H.wear_mask) H.wear_mask.screen_loc = null


/datum/hud/proc/persistant_inventory_update()
	if(!mymob)
		return

	if(ishuman(mymob))
		var/mob/living/carbon/human/H = mymob
		for(var/gear_slot in H.species.hud.gear)
			var/list/hud_data = H.species.hud.gear[gear_slot]
			if(hud_shown)
				switch(hud_data["slot"])
					if(slot_s_store)
						if(H.s_store) H.s_store.screen_loc = hud_data["loc"]
					if(slot_wear_id)
						if(H.wear_id) H.wear_id.screen_loc = hud_data["loc"]
					if(slot_belt)
						if(H.belt)    H.belt.screen_loc =    hud_data["loc"]
					if(slot_back)
						if(H.back)    H.back.screen_loc =    hud_data["loc"]
					if(slot_l_store)
						if(H.l_store) H.l_store.screen_loc = hud_data["loc"]
					if(slot_r_store)
						if(H.r_store) H.r_store.screen_loc = hud_data["loc"]
			else
				switch(hud_data["slot"])
					if(slot_s_store)
						if(H.s_store) H.s_store.screen_loc = null
					if(slot_wear_id)
						if(H.wear_id) H.wear_id.screen_loc = null
					if(slot_belt)
						if(H.belt)    H.belt.screen_loc =    null
					if(slot_back)
						if(H.back)    H.back.screen_loc =    null
					if(slot_l_store)
						if(H.l_store) H.l_store.screen_loc = null
					if(slot_r_store)
						if(H.r_store) H.r_store.screen_loc = null


/datum/hud/proc/instantiate()
	if(!ismob(mymob))
		return 0

	toggle_palette = new()
	palette_down = new()
	palette_up = new()
	mymob.create_mob_hud(src)

	// Past this point, mymob.hud_used is set

	toggle_palette.set_hud(src)
	palette_down.set_hud(src)
	palette_up.set_hud(src)

	persistant_inventory_update()
	mymob.reload_fullscreen() // Reload any fullscreen overlays this mob has.
	mymob.update_action_buttons(TRUE)
	reorganize_alerts()

/mob/proc/create_mob_hud(datum/hud/HUD, apply_to_client = TRUE)
	if(!client)
		return 0

	HUD.ui_style = ui_style2icon(read_preference(/datum/preference/choiced/ui_style))
	HUD.ui_color = read_preference(/datum/preference/color/ui_style_color)
	HUD.ui_alpha = read_preference(/datum/preference/numeric/ui_style_alpha)
	set_hud_used(HUD)

/mob/proc/set_hud_used(datum/hud/new_hud)
	hud_used = new_hud
	new_hud.build_action_groups()

/mob/proc/update_ui_style(UI_style_new, UI_style_alpha_new, UI_style_color_new)
	if(!hud_used)
		return

	if(!UI_style_alpha_new)
		UI_style_alpha_new = hud_used.ui_alpha
	hud_used.ui_alpha = UI_style_alpha_new
	if(!UI_style_color_new)
		UI_style_color_new = hud_used.ui_color
	hud_used.ui_color = UI_style_color_new

	var/list/icons = hud_used.adding + hud_used.other + hud_used.hotkeybuttons + hud_used.other_important
	icons.Add(zone_sel)
	icons.Add(gun_setting_icon)
	icons.Add(item_use_icon)
	icons.Add(gun_move_icon)
	icons.Add(radio_use_icon)

	var/icon/ic

	if(UI_style_new)
		if(isrobot(src))
			ic = all_ui_styles_robot[UI_style_new]
		else
			ic = all_ui_styles[UI_style_new]
		hud_used.ui_style = ic
	else
		ic = hud_used.ui_style

	for(var/obj/screen/I in icons)
		if(I.name in list(I_HELP, I_HURT, I_DISARM, I_GRAB))
			continue
		if(!(I.name in list("check known languages", "autowhisper", "autowhisper mode", "move downwards", "move upwards", "set pose")))
			I.icon = ic
		I.color = UI_style_color_new
		I.alpha = UI_style_alpha_new

/datum/hud/proc/apply_minihud(var/datum/mini_hud/MH)
	if(MH in minihuds)
		return
	minihuds += MH
	if(mymob.client)
		mymob.client.screen -= miniobjs
	miniobjs += MH.get_screen_objs()
	if(mymob.client)
		mymob.client.screen += miniobjs

/datum/hud/proc/remove_minihud(var/datum/mini_hud/MH)
	if(!(MH in minihuds))
		return
	minihuds -= MH
	if(mymob.client)
		mymob.client.screen -= miniobjs
	miniobjs -= MH.get_screen_objs()
	if(mymob.client)
		mymob.client.screen += miniobjs

//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12(var/full = 0 as null)
	set name = "F12"
	set hidden = 1

	if(!hud_used)
		to_chat(src, span_warning("This mob type does not use a HUD."))
		return FALSE
	if(!client)
		return FALSE
	if(client.view != world.view)
		return FALSE

	toggle_hud_vis(full)

/mob/proc/toggle_hud_vis(full)
	if(!client)
		return FALSE

	if(hud_used.hud_shown)
		hud_used.hud_shown = 0
		if(hud_used.adding)
			client.screen -= hud_used.adding
		if(hud_used.other)
			client.screen -= hud_used.other
		if(hud_used.hotkeybuttons)
			client.screen -= hud_used.hotkeybuttons
		if(hud_used.other_important)
			client.screen -= hud_used.other_important
	else
		hud_used.hud_shown = 1
		if(hud_used.adding)
			client.screen += hud_used.adding
		if(hud_used.other && hud_used.inventory_shown)
			client.screen += hud_used.other
		if(hud_used.other_important)
			client.screen += hud_used.other_important
		if(hud_used.hotkeybuttons && !hud_used.hotkey_ui_hidden)
			client.screen += hud_used.hotkeybuttons
		if(healths)
			client.screen |= healths
		if(internals)
			client.screen |= internals
		if(gun_setting_icon)
			client.screen |= gun_setting_icon

		hud_used?.action_intent.screen_loc = ui_acti //Restore intent selection to the original position
		client.screen += zone_sel				//This one is a special snowflake
		client.screen += hud_used.toggle_palette

	hud_used.hidden_inventory_update()
	hud_used.persistant_inventory_update()
	update_action_buttons(TRUE)
	hud_used.reorganize_alerts()
	return TRUE

/mob/living/carbon/human/toggle_hud_vis(full)
	if(!(. = ..()))
		return FALSE

	// Prevents humans from hiding a few hud elements
	if(!hud_used.hud_shown) // transitioning to hidden
		//Due to some poor coding some things need special treatment:
		//These ones are a part of 'adding', 'other' or 'hotkeybuttons' but we want them to stay
		if(!full)
			client.screen += hud_used.l_hand_hud_object	//we want the hands to be visible
			client.screen += hud_used.r_hand_hud_object	//we want the hands to be visible
			client.screen += hud_used.action_intent		//we want the intent swticher visible
			hud_used?.action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.
		else
			client.screen -= healths
			client.screen -= internals
			client.screen -= gun_setting_icon

		//These ones are not a part of 'adding', 'other' or 'hotkeybuttons' but we want them gone.
		client.screen -= zone_sel	//zone_sel is a mob variable for some reason.

//Similar to button_pressed_F12() but keeps zone_sel, gun_setting_icon, and healths.
/mob/proc/toggle_zoom_hud()
	if(!hud_used)
		return
	if(!ishuman(src))
		return
	if(!client)
		return
	if(client.view != world.view)
		return

	if(hud_used.hud_shown)
		hud_used.hud_shown = 0
		if(src.hud_used.adding)
			src.client.screen -= src.hud_used.adding
		if(src.hud_used.other)
			src.client.screen -= src.hud_used.other
		if(src.hud_used.hotkeybuttons)
			src.client.screen -= src.hud_used.hotkeybuttons
		src.client.screen -= src.internals
		src.client.screen += src.hud_used.action_intent		//we want the intent swticher visible
	else
		hud_used.hud_shown = 1
		if(src.hud_used.adding)
			src.client.screen += src.hud_used.adding
		if(src.hud_used.other && src.hud_used.inventory_shown)
			src.client.screen += src.hud_used.other
		if(src.hud_used.hotkeybuttons && !src.hud_used.hotkey_ui_hidden)
			src.client.screen += src.hud_used.hotkeybuttons
		if(src.internals)
			src.client.screen |= src.internals
		src.hud_used.action_intent.screen_loc = ui_acti //Restore intent selection to the original position

	hud_used.hidden_inventory_update()
	hud_used.persistant_inventory_update()
	update_action_buttons(TRUE)

/mob/proc/add_click_catcher()
	client.screen += client.void

/mob/new_player/add_click_catcher()
	return

/mob/living/create_mob_hud(datum/hud/HUD, apply_to_client = TRUE)
	..()

	var/list/hud_elements = list()
	shadekin_display = new /obj/screen/shadekin()
	shadekin_display.screen_loc = ui_shadekin_display
	shadekin_display.icon_state = "shadekin"
	hud_elements |= shadekin_display

	xenochimera_danger_display = new /obj/screen/xenochimera/danger_level()
	xenochimera_danger_display.screen_loc = ui_xenochimera_danger_display
	xenochimera_danger_display.icon_state = "danger00"
	hud_elements |= xenochimera_danger_display

	lleill_display = new /obj/screen/lleill()
	lleill_display.screen_loc = ui_lleill_display
	lleill_display.icon_state = "lleill"
	hud_elements |= lleill_display

	if(client)
		client.screen = list()

		client.screen += hud_elements
		client.screen += client.void

/* TGMC Ammo HUD Port
 * These procs call to screen_objects.dm's respective procs.
 * All these do is manage the amount of huds on screen and set the HUD.
*/
///Add an ammo hud to the user informing of the ammo count of G
/datum/hud/proc/add_ammo_hud(mob/living/user, obj/item/gun/G)
	if(length(ammo_hud_list) >= MAX_AMMO_HUD_POSSIBLE)
		return
	var/obj/screen/ammo/ammo_hud = new
	ammo_hud_list[G] = ammo_hud
	ammo_hud.screen_loc = ammo_hud.ammo_screen_loc_list[length(ammo_hud_list)]
	ammo_hud.add_hud(user, G)
	ammo_hud.update_hud(user, G)

///Remove the ammo hud related to the gun G from the user
/datum/hud/proc/remove_ammo_hud(mob/living/user, obj/item/gun/G)
	var/obj/screen/ammo/ammo_hud = ammo_hud_list[G]
	if(isnull(ammo_hud))
		return
	ammo_hud.remove_hud(user, G)
	qdel(ammo_hud)
	ammo_hud_list -= G
	var/i = 1
	for(var/key in ammo_hud_list)
		ammo_hud = ammo_hud_list[key]
		ammo_hud.screen_loc = ammo_hud.ammo_screen_loc_list[i]
		i++

///Update the ammo hud related to the gun G
/datum/hud/proc/update_ammo_hud(mob/living/user, obj/item/gun/G)
	var/obj/screen/ammo/ammo_hud = ammo_hud_list[G]
	ammo_hud?.update_hud(user, G)

#undef MAX_AMMO_HUD_POSSIBLE
