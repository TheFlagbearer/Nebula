/datum/nano_module/appearance_changer
	name = "Appearance Editor"
	available_to_ai = FALSE
	var/flags = APPEARANCE_ALL_HAIR
	var/mob/living/carbon/human/owner = null
	var/list/valid_species = list()
	var/list/valid_hairstyles = list()
	var/list/valid_facial_hairstyles = list()

	var/check_whitelist
	var/list/whitelist
	var/list/blacklist

/datum/nano_module/appearance_changer/New(var/location, var/mob/living/carbon/human/H, var/check_species_whitelist = 1, var/list/species_whitelist = list(), var/list/species_blacklist = list())
	..()
	owner = H
	src.check_whitelist = check_species_whitelist
	src.whitelist = species_whitelist
	src.blacklist = species_blacklist

/datum/nano_module/appearance_changer/Topic(ref, href_list, var/datum/topic_state/state = GLOB.default_state)
	if(..())
		return 1

	if(href_list["race"])
		if(can_change(APPEARANCE_RACE) && (href_list["race"] in valid_species))
			if(owner.change_species(href_list["race"]))
				cut_and_generate_data()
				return 1
	if(href_list["gender"])
		if(can_change(APPEARANCE_GENDER))
			var/decl/pronouns/pronouns = get_pronouns_by_gender(href_list["gender"])
			if(istype(pronouns) && (pronouns in owner.species.available_pronouns))
				if(owner.set_gender(pronouns.name, TRUE))
					cut_and_generate_data()
					return 1
	if(href_list["bodytype"])
		if(can_change(APPEARANCE_BODY))
			var/decl/species/species = owner.get_species()
			var/decl/bodytype/B = species.get_bodytype_by_name(href_list["bodytype"])
			if(istype(B) && (B in owner.species.available_bodytypes))
				if(owner.set_bodytype(B, TRUE))
					cut_and_generate_data()
					return 1
	if(href_list["skin_tone"])
		if(can_change_skin_tone())
			var/new_s_tone = input(usr, "Choose your character's skin-tone:\n1 (lighter) - [owner.species.max_skin_tone()] (darker)", "Skin Tone", -owner.skin_tone + 35) as num|null
			if(isnum(new_s_tone) && can_still_topic(state) && owner.species.appearance_flags & HAS_SKIN_TONE_NORMAL)
				new_s_tone = 35 - max(min(round(new_s_tone), owner.species.max_skin_tone()), 1)
				return owner.change_skin_tone(new_s_tone)
	if(href_list["skin_color"])
		if(can_change_skin_color())
			var/new_skin = input(usr, "Choose your character's skin colour: ", "Skin Color", owner.skin_colour) as color|null
			if(new_skin && can_still_topic(state) && owner.change_skin_color(new_skin))
				update_dna()
				return TRUE
	if(href_list["hair"])
		if(can_change(APPEARANCE_HAIR) && (href_list["hair"] in valid_hairstyles))
			if(owner.change_hair(href_list["hair"]))
				update_dna()
				return 1
	if(href_list["hair_color"])
		if(can_change(APPEARANCE_HAIR_COLOR))
			var/new_hair = input("Please select hair color.", "Hair Color", owner.hair_colour) as color|null
			if(new_hair && can_still_topic(state) && owner.change_hair_color(new_hair))
				update_dna()
				return TRUE
	if(href_list["facial_hair"])
		if(can_change(APPEARANCE_FACIAL_HAIR) && (href_list["facial_hair"] in valid_facial_hairstyles))
			if(owner.change_facial_hair(href_list["facial_hair"]))
				update_dna()
				return 1
	if(href_list["facial_hair_color"])
		if(can_change(APPEARANCE_FACIAL_HAIR_COLOR))
			var/new_facial = input("Please select facial hair color.", "Facial Hair Color", owner.facial_hair_colour) as color|null
			if(new_facial && can_still_topic(state) && owner.change_facial_hair_color(new_facial))
				update_dna()
				return TRUE
	if(href_list["eye_color"])
		if(can_change(APPEARANCE_EYE_COLOR))
			var/new_eyes = input("Please select eye color.", "Eye Color", owner.eye_colour) as color|null
			if(new_eyes && can_still_topic(state) && owner.change_eye_color(new_eyes))
				update_dna()
				return TRUE
	return 0

/datum/nano_module/appearance_changer/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.default_state)
	if(!owner || !owner.species)
		return

	generate_data(check_whitelist, whitelist, blacklist)
	var/list/data = host.initial_data()

	data["specimen"] = owner.species.name
	data["gender"] = owner.gender
	data["change_race"] = can_change(APPEARANCE_RACE)
	if(data["change_race"])
		var/species[0]
		for(var/specimen in valid_species)
			species[++species.len] =  list("specimen" = specimen)
		data["species"] = species

	data["change_gender"] = can_change(APPEARANCE_GENDER)
	if(data["change_gender"])
		var/genders[0]
		for(var/decl/pronouns/G as anything in owner.species.available_pronouns)
			genders[++genders.len] =  list("gender_name" = capitalize(G.name), "gender_key" = G.name)
		data["genders"] = genders

	data["bodytype"] = capitalize(owner.bodytype.name)
	data["change_bodytype"] = can_change(APPEARANCE_BODY)
	if(data["change_bodytype"])
		var/bodytypes[0]
		for(var/decl/bodytype/B as anything in owner.species.available_bodytypes)
			bodytypes += capitalize(B.name)
		data["bodytypes"] = bodytypes

	data["change_skin_tone"] = can_change_skin_tone()
	data["change_skin_color"] = can_change_skin_color()
	data["change_eye_color"] = can_change(APPEARANCE_EYE_COLOR)
	data["change_hair"] = can_change(APPEARANCE_HAIR)
	if(data["change_hair"])
		var/hair_styles[0]
		for(var/hair_style in valid_hairstyles)
			hair_styles[++hair_styles.len] = list("hairstyle" = hair_style)
		data["hair_styles"] = hair_styles
		data["hair_style"] = owner.h_style

	data["change_facial_hair"] = can_change(APPEARANCE_FACIAL_HAIR)
	if(data["change_facial_hair"])
		var/facial_hair_styles[0]
		for(var/facial_hair_style in valid_facial_hairstyles)
			facial_hair_styles[++facial_hair_styles.len] = list("facialhairstyle" = facial_hair_style)
		data["facial_hair_styles"] = facial_hair_styles
		data["facial_hair_style"] = owner.f_style

	data["change_hair_color"] = can_change(APPEARANCE_HAIR_COLOR)
	data["change_facial_hair_color"] = can_change(APPEARANCE_FACIAL_HAIR_COLOR)
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "appearance_changer.tmpl", "[src]", 800, 450, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/datum/nano_module/appearance_changer/proc/update_dna()
	if(owner && (flags & APPEARANCE_UPDATE_DNA))
		owner.update_dna()

/datum/nano_module/appearance_changer/proc/can_change(var/flag)
	return owner && (flags & flag)

/datum/nano_module/appearance_changer/proc/can_change_skin_tone()
	return owner && (flags & APPEARANCE_SKIN) && owner.species.appearance_flags & HAS_A_SKIN_TONE

/datum/nano_module/appearance_changer/proc/can_change_skin_color()
	return owner && (flags & APPEARANCE_SKIN) && owner.species.appearance_flags & HAS_SKIN_COLOR

/datum/nano_module/appearance_changer/proc/cut_and_generate_data()
	// Making the assumption that the available species remain constant
	valid_facial_hairstyles.Cut()
	valid_facial_hairstyles.Cut()
	generate_data()

/datum/nano_module/appearance_changer/proc/generate_data()
	if(!owner)
		return
	if(!valid_species.len)
		valid_species = owner.generate_valid_species(check_whitelist, whitelist, blacklist)
	if(!valid_hairstyles.len || !valid_facial_hairstyles.len)
		valid_hairstyles = owner.generate_valid_hairstyles(check_gender = 0)
		valid_facial_hairstyles = owner.generate_valid_facial_hairstyles()
