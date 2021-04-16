[
	"CURATORHUD_settings_isEnabled", // Internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
	"CHECKBOX", // setting type
	"Enable Curator HUD", // Pretty name shown inside the ingame settings menu. Can be stringtable entry.
	"Curator HUD", // Pretty name of the category where the setting can be found. Can be stringtable entry.
	true, // default value
	nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
	{  
		params ["_value"];
		CURATORHUD_isEnabled = _value;
	} // function that will be executed once on mission start and every time the setting is changed.
] call CBA_fnc_addSetting;

[
	"CURATORHUD_settings_doDebugOutput", // Internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
	"CHECKBOX", // setting type
	"Show Debug Output", // Pretty name shown inside the ingame settings menu. Can be stringtable entry.
	"Curator HUD", // Pretty name of the category where the setting can be found. Can be stringtable entry.
	false, // default value
	nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
	{  
		params ["_value"];
		CURATORHUD_doDebugOutput = _value;
	} // function that will be executed once on mission start and every time the setting is changed.
] call CBA_fnc_addSetting;

[
	"CURATORHUD_settings_outputStyle", // Internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
	"LIST", // setting type
	"Display Style", // Pretty name shown inside the ingame settings menu. Can be stringtable entry.
	"Curator HUD", // Pretty name of the category where the setting can be found. Can be stringtable entry.
	[["monospaced", "numbers"], ["Monospace Colored", "Numbers"], 0], // data for this setting
	nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
	{  
		params ["_value"];
		CURATORHUD_outputStyle = _value;
	} // function that will be executed once on mission start and every time the setting is changed.
] call CBA_fnc_addSetting;

[
	"CURATORHUD_settings_newlineAfterXGroups", // Internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
	"SLIDER", // setting type
	"Groups per Line", // Pretty name shown inside the ingame settings menu. Can be stringtable entry.
	"Curator HUD", // Pretty name of the category where the setting can be found. Can be stringtable entry.
	[1, 8, 4, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
	nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
	{  
		params ["_value"];
		CURATORHUD_newlineAfterXGroups = _value;
	} // function that will be executed once on mission start and every time the setting is changed.
] call CBA_fnc_addSetting;

[
	"CURATORHUD_settings_hudUpdateInterval", // Internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
	"SLIDER", // setting type
	"Update Interval", // Pretty name shown inside the ingame settings menu. Can be stringtable entry.
	"Curator HUD", // Pretty name of the category where the setting can be found. Can be stringtable entry.
	[1, 30, 1, 0], // data for this setting: [min, max, default, number of shown trailing decimals]
	nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
	{  
		params ["_value"];
		CURATORHUD_updateIntervalInSeconds = _value;
	} // function that will be executed once on mission start and every time the setting is changed.
] call CBA_fnc_addSetting;

[
	"CURATORHUD_settings_position", // Internal setting name, should always contain a tag! This will be the global variable which takes the value of the setting.
	"LIST", // setting type
	"HUD Position", // Pretty name shown inside the ingame settings menu. Can be stringtable entry.
	"Curator HUD", // Pretty name of the category where the setting can be found. Can be stringtable entry.
	[["left", "center"], ["Top Left", "Top Center"], 0], // data for this setting
	nil, // "_isGlobal" flag. Set this to true to always have this setting synchronized between all clients in multiplayer
	{  
		params ["_value"];
		CURATORHUD_position = _value;
	} // function that will be executed once on mission start and every time the setting is changed.
] call CBA_fnc_addSetting;
