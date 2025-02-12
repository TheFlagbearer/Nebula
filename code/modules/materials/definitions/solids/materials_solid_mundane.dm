/decl/material/solid/slag
	name = "slag"
	stack_type = null
	color = "#2e3a07"
	ore_name = "slag"
	ore_desc = "Someone messed up..."
	ore_icon_overlay = "lump"
	hidden_from_codex = TRUE
	reflectiveness = MAT_VALUE_DULL
	wall_support_value = MAT_VALUE_LIGHT
	value = 0.1
	// Slag can be reclaimed into more useful forms by grinding it up and mixing it with strong acid.
	dissolves_in = MAT_SOLVENT_STRONG
	dissolves_into = list(
		/decl/material/solid/mineral/sand =    0.7,
		/decl/material/solid/metal/iron =      0.1,
		/decl/material/solid/metal/aluminium = 0.05,
		/decl/material/solid/phosphorus =      0.05,
		/decl/material/gas/sulfur_dioxide =    0.05,
		/decl/material/gas/carbon_dioxide =    0.05
	)
