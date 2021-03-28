#include "\a3\ui_f\hpp\defineCommonGrids.inc"

import RscStructuredText;

#define INFINITE 1e+1000
class RscTitles
{
	class RscMyHUD_Empty
	{
		idd = -1;
		duration = 0;
		fadeIn = 0;
		fadeOut = 0;
	};

	class RscTeamHealthHUD
	{
		idd = 2021032702;
		enableSimulation = 1;
		enableDisplay = 1;
		onLoad = "uiNamespace setVariable ['ZO_RscTeamHealthHUD', _this select 0];";
		duration = INFINITE;
		fadeIn = 1;
		fadeOut = 1;
		name = "RscTeamHealthHUD";
		class Controls
		{
			class CenterText: RscStructuredText
			{
				idc = 4591;
				text = "Team Health HUD";
				x = GUI_GRID_TOPCENTER_X + (12 * GUI_GRID_TOPCENTER_W);
				y = GUI_GRID_TOPCENTER_Y + (4 * GUI_GRID_TOPCENTER_H);
				w = 5 * GUI_GRID_TOPCENTER_W;
				h = 1 * GUI_GRID_TOPCENTER_H;
				colorBackground[] = {0,0,0,0.8};
			};
		};
	};

};
