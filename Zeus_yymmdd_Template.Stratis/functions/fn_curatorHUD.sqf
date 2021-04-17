#include "\a3\ui_f\hpp\definecommongrids.inc"

null=[]spawn {
	disableSerialization;

	if (!hasInterface) exitWith {};

	// Settings - Start
	CURATORHUD_isEnabled = true;
	CURATORHUD_doDebugOutput = false;
	CURATORHUD_outputStyle = "monospaced"; // Valid are: monospaced, numbers
	CURATORHUD_newlineAfterXGroups = 3;
	CURATORHUD_updateIntervalInSeconds = 1;
	CURATORHUD_position = "left"; // Valid are: left, center
	// Settings - End

	private _id = ["CuratorHUDLayer"] call BIS_fnc_rscLayer;
	private _isCtrlTextCreated = false;
	private _ctrlText = nil;
	while {true} do {
		// Check if is Zeus/CuratorHUDLayer
		if ((!isNull (getAssignedCuratorLogic player)) && CURATORHUD_isEnabled) then {
			if (CURATORHUD_doDebugOutput) then { systemChat "Player is Zeus/Curator."; };

			_id cutRsc ["RscTeamHealthHUD", "PLAIN"];
			_isCtrlTextCreated = true;

			waitUntil {!isNull (uiNameSpace getVariable "ZO_RscTeamHealthHUD")};
			private _display = uiNameSpace getVariable "ZO_RscTeamHealthHUD";
			_ctrlText = _display displayCtrl 1741;

			private _headlessClients 	= entities "HeadlessClient_F";
			private curatorPlayers 		= [];
			{
				if (!isNull (getAssignedCuratorLogic _x)) then {
					curatorPlayers pushBackUnique _x;
				};
			} forEach allPlayers;

			private _humanPlayers = (allPlayers - _headlessClients) - curatorPlayers;
			if (CURATORHUD_doDebugOutput) then { systemChat format ["We currently have %1 human players and %2 HCs.", count _humanPlayers, count _headlessClients]; };

			private _allGroupsWithPlayers = [];
			{_allGroupsWithPlayers pushBackUnique group _x} forEach _humanPlayers;
			
			// For debugging in SP/MP without players:
			//_allGroupsWithPlayers = allGroups;
			if (CURATORHUD_doDebugOutput) then { systemChat format ["We currently have %1 groups with players.", count _allGroupsWithPlayers]; };

			private _showLeader = true;

			private _groupsOutputArray 		= [];
			private _groupsOutputArrayMono 	= [];
			private _groupCounter 			= 0;
			{
				private _group 						= _x;
				private _groupName 					= groupId _group;
				private _groupLeader 				= leader _group;
				private _groupLeaderName			= [_groupLeader] call BIS_fnc_getName;
				private _groupPlayers 				= units _group;
				private _groupPlayerCount			= count _groupPlayers;
				private _playersHealthyArray 		= [];
				private _playersInjuredArray 		= [];
				private _playersHeavilyInjuredArray = [];
				private _playersDownedArray 		= [];
				private _playersDeadArray 			= [];
				private _playersOutputArray	 		= [];
				private _playersMonoOutput			= [];
				
				{
					private _player				= _x;
					private _playerName 		= [_player] call BIS_fnc_getName;
					private _isLeader			= (_player == _groupLeader);
					private _leaderString		= if (_isLeader) then [ { " (L)" }, { "" } ];
					private _lifeState 			= lifeState _player;
					private _isHealthy			= (_lifeState == "HEALTHY");
					private _playerFont			= if (_isLeader) then [ { "EtelkaMonospaceProBold" }, { "EtelkaMonospacePro" } ];
					if (_lifeState == "DEAD" || (!alive _player)) then {
						_playersDeadArray pushBack _playerName;
						_playersMonoOutput pushBack format ["<t size='1.0' font='%1' color='#D40004'>_</t>", _playerFont];
					} else {
						if (!_isHealthy) then {
							_playersDownedArray pushBack _playerName;
							_playersMonoOutput pushBack format ["<t size='1.0' font='%1' color='#D97E00'>-</t>", _playerFont];
						} else {
							// Sum up the hitStates
							private _playerHitStates = getAllHitPointsDamage _player;
							//if (CURATORHUD_doDebugOutput) then { systemChat format ["Player is %1 (name = %2), lifeState = %3 and hit-states has %4 entries.", _player, _playerName, _lifeState, count _playerHitStates]; };
							private _playerHitValues = if ((count _playerHitStates) > 0) then { _playerHitStates select 2 } else { [] };
							private _playerHitSum = 0.0;
							{
								_playerHitSum = _playerHitSum + _x;
							} forEach _playerHitValues;
							if (_playerHitSum >= 0.4) then {
								_playersInjuredArray pushBack _playerName;
								if (_playerHitSum >= 1.0) then {
									_playersHeavilyInjuredArray pushBack _playerName;
									_playersMonoOutput pushBack format ["<t size='1.0' font='%1' color='#D97E00'>I</t>", _playerFont];
								} else {
									_playersMonoOutput pushBack format ["<t size='1.0' font='%1' color='#F0F03A'>I</t>", _playerFont];
								};
							} else {
								_playersHealthyArray pushBack _playerName;
								_playersMonoOutput pushBack format ["<t size='1.0' font='%1' color='#0A9B00'>H</t>", _playerFont];
							};
						};
					};

					private _playersText = format ["%1%2 (%3)", _playerName, _leaderString, _lifeState];
					_playersOutputArray pushBack _playersText;
				} forEach _groupPlayers;
				
				private _groupPlayersHealthyCount 			= count _playersHealthyArray;
				private _groupPlayersDownedCount 			= count _playersDownedArray;
				private _groupPlayersInjuredCount 			= count _playersInjuredArray;
				private _groupPlayersHeavilyInjuredCount 	= count _playersHeavilyInjuredArray;
				private _groupPlayersDeadCount 				= count _playersDeadArray;
				private _color = "#000000";
				if (_groupPlayersHealthyCount >= (0.75 * _groupPlayerCount)) then {
					_color = "#0A9B00"; // Green
				} else {
					if (_groupPlayersHealthyCount >= (0.5 * _groupPlayerCount)) then {
						_color = "#F0F03A"; // Yellow
					} else {
						if (_groupPlayersHealthyCount >= (0.25 * _groupPlayerCount)) then {
							_color = "#D97E00"; // Orange
						} else {
							_color = "#D40004";
						};
					};
				};
				
				// Or if half of the team is heavily injured or dead.
				if ((_groupPlayersHeavilyInjuredCount + _groupPlayersDeadCount + _groupPlayersDownedCount) >= (0.5 * _groupPlayerCount)) then {
					_color = "#D40004"; // Red
				};

				private _groupOutNewline = "";
				// If this is the next extra after a _newlineAfterXGroups roll-over was reached, prepend a newline.
				if ((CURATORHUD_newlineAfterXGroups > 0) && (_groupCounter > 0) && ((_groupCounter mod CURATORHUD_newlineAfterXGroups) == 0)) then {
					_groupOutNewline = "<br/>";
				};

				private _groupText = format ["%8<t size='1.0' color='%1'>%2: %3H/%4I/%5U/%6D/%7T</t>", _color, _groupName, _groupPlayersHealthyCount, _groupPlayersInjuredCount, _groupPlayersDownedCount, _groupPlayersDeadCount, _groupPlayerCount, _groupOutNewline];
				_groupsOutputArray pushBack _groupText;
				private _groupTextMono = format ["%4<t size='1.0' color='%1'>%2:</t> %3", _color, _groupName, _playersMonoOutput joinString "", _groupOutNewline];
				_groupsOutputArrayMono pushBack _groupTextMono;

				// Increment group counter
				_groupCounter = _groupCounter + 1;
			} forEach (_allGroupsWithPlayers);

			private _finalText 		= _groupsOutputArray joinString ", ";
			private _finalTextMono 	= _groupsOutputArrayMono joinString ", ";

			if (CURATORHUD_outputStyle == "monospaced") then {
				_ctrlText ctrlSetStructuredText parseText _finalTextMono;
			} else {
				if (CURATORHUD_outputStyle == "numbers") then {
					_ctrlText ctrlSetStructuredText parseText _groupsOutputArray;
				} else {
					systemChat format ["Invalid output style: %1", CURATORHUD_outputStyle];
					_ctrlText ctrlSetStructuredText parseText format ["Invalid output style: %1", CURATORHUD_outputStyle];
				};
			};
			_ctrlText ctrlSetBackgroundColor [0,0,0,0.5];

			// Set position
			if (CURATORHUD_position == "left") then {
				_ctrlText ctrlSetPositionX (GUI_GRID_TOPCENTER_X + (0 * GUI_GRID_TOPCENTER_W));
			} else {
				if (CURATORHUD_position == "center") then {
					_ctrlText ctrlSetPositionX (GUI_GRID_TOPCENTER_X + (12 * GUI_GRID_TOPCENTER_W));
				} else {
					systemChat format ["Invalid output position: %1", CURATORHUD_position];
				};
			};

			// Fix width/height
			private _width = ctrlTextWidth _ctrlText;
			_ctrlText ctrlSetPositionW _width + 2 * 0.008; // This double set/commit is necessary to calculate the correct height using the new width...
			_ctrlText ctrlCommit 0;
			private _height = ctrlTextHeight _ctrlText;
			_ctrlText ctrlSetPositionH _height;
			_ctrlText ctrlCommit 0;
			
			uiSleep CURATORHUD_updateIntervalInSeconds;
		} else {
			if (!CURATORHUD_isEnabled) then {
				if (CURATORHUD_doDebugOutput) then { systemChat "HUD is disabled."; };
				if (_isCtrlTextCreated) then {
					_ctrlText ctrlSetBackgroundColor [0,0,0,0];
					_ctrlText ctrlSetText "";
					_ctrlText ctrlSetPositionW 0;
					_ctrlText ctrlSetPositionH 0;
				};
				uiSleep 5;
			} else {
				uiSleep 15;
				if (CURATORHUD_doDebugOutput) then { systemChat "Player is NOT Zeus/Curator."; };
			};
		};
	};
}
