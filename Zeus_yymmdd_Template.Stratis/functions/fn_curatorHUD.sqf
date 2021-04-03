
null=[]spawn {
	disableSerialization;

	if (!hasInterface) exitWith {};

	private _doDebugOutput = true;

	private _id = ["CuratorHUDLayer"] call BIS_fnc_rscLayer;
	while {true} do {
		// Check if is Zeus/CuratorHUDLayer
		if (!isNull (getAssignedCuratorLogic player)) then {
			if (_doDebugOutput) then { systemChat "Player is Zeus/Curator."; };

			_id cutRsc ["RscTeamHealthHUD", "PLAIN"];

			private _name = name player;
			private _time = time;

			waitUntil {!isNull (uiNameSpace getVariable "ZO_RscTeamHealthHUD")};
			_display = uiNameSpace getVariable "ZO_RscTeamHealthHUD";
			_ctrlText = _display displayCtrl 1741;

			private _headlessClients = entities "HeadlessClient_F";
			private _humanPlayers = allPlayers - _headlessClients;
			if (_doDebugOutput) then { systemChat format ["We currently have %1 human players and %2 HCs.", count _humanPlayers, count _headlessClients]; };

			private _allGroupsWithPlayers = [];
			{_allGroupsWithPlayers pushBackUnique group _x} forEach _humanPlayers;
			if (_doDebugOutput) then { systemChat format ["We currently have %1 groups with players.", count _allGroupsWithPlayers]; };

			private _showLeader = true;

			private _groupsOutputArray = [];
			private _groupsOutputArrayMono = [];
			{
				private _group = _x;
				private _groupName 				= groupId _group;
				private _groupLeader 		= leader _group;
				private _groupLeaderName	= [_groupLeader] call BIS_fnc_getName;
				private _groupPlayers 		= units _group;
				private _groupPlayerCount	= count _groupPlayers;
				private _playersHealthyArray = [];
				private _playersInjuredArray = [];
				private _playersHeavilyInjuredArray = [];
				private _playersDownedArray = [];
				private _playersDeadArray = [];
				private _playersOutputArray = [];
				private _playersMonoOutput = [];
				
				{
					private _player				= _x;
					private _playerName 		= [_player] call BIS_fnc_getName;
					private _isLeader			= _player == _groupLeader;
					private _leaderString		= if (_isLeader) then [ { " (L)" }, { "" } ];
					private _lifeState 			= lifeState _player;
					private _isHealthy			= _lifeState == "HEALTHY";
					if (_lifeState == "DEAD" || (!alive _player)) then {
						_playersDeadArray pushBack _playerName;
						_playersMonoOutput pushBack "<t size='1.0' font='EtelkaMonospacePro' color='#D40004'>_</t>";
					} else {
						if (!_isHealthy) then {
							_playersDownedArray pushBack _playerName;
							_playersMonoOutput pushBack "<t size='1.0' font='EtelkaMonospacePro' color='#D97E00'>-</t>";
						} else {
							// Sum up the hitStates
							private _playerHitStates = getAllHitPointsDamage _player;
							private _playerHitValues = _playerHitStates select 2;
							private _playerHitSum = 0.0;
							{
								_playerHitSum = _playerHitSum + _x
							} forEach _playerHitValues;
							if (_playerHitSum >= 0.4) then {
								_playersInjuredArray pushBack _playerName;
								if (_playerHitSum >= 1.0) then {
									_playersHeavilyInjuredArray pushBack _playerName;
									_playersMonoOutput pushBack "<t size='1.0' font='EtelkaMonospacePro' color='#D97E00'>I</t>";
								} else {
									_playersMonoOutput pushBack "<t size='1.0' font='EtelkaMonospacePro' color='#F0F03A'>I</t>";
								};
							} else {
								_playersHealthyArray pushBack _playerName;
								_playersMonoOutput pushBack "<t size='1.0' font='EtelkaMonospacePro' color='#0A9B00'>H</t>";
							};
						};
					};

					private _playersText		= format ["%1%2 (%3)", _playerName, _leaderString, _lifeState];
					_playersOutputArray pushBack _playersText;
				} forEach _groupPlayers;
				
				private _groupPlayersHealthyCount = count _playersHealthyArray;
				private _groupPlayersDownedCount = count _playersDownedArray;
				private _groupPlayersInjuredCount = count _playersInjuredArray;
				private _groupPlayersHeavilyInjuredCount = count _playersHeavilyInjuredArray;
				private _groupPlayersDeadCount = count _playersDeadArray;
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

				//private _deadString = if (_groupPlayersDeadCount > 0) then [ { format [" (Dead: %1)", _groupPlayersDeadCount] }, { "" } ];
				private _groupText = format ["<t size='1.0' color='%1'>%2: %3H/%4I/%5U/%6D/%7T</t>", _color, _groupName, _groupPlayersHealthyCount, _groupPlayersInjuredCount, _groupPlayersDownedCount, _groupPlayersDeadCount, _groupPlayerCount];
				_groupsOutputArray pushBack _groupText;
				private _groupTextMono = format ["<t size='1.0' color='%1'>%2:</t> %3", _color, _groupName, _playersMonoOutput joinString ""];
				_groupsOutputArrayMono pushBack _groupTextMono;
			} forEach (_allGroupsWithPlayers);

			private _finalText = _groupsOutputArray joinString ", ";
			private _finalTextMono = _groupsOutputArrayMono joinString ", ";

			_ctrlText ctrlSetStructuredText parseText _finalTextMono;
			_ctrlText ctrlSetBackgroundColor [0,0,0,0.5];

			// Fix width/height
			private _width = ctrlTextWidth _ctrlText;
			private _height = ctrlTextHeight _ctrlText;
			private _oldPos = ctrlPosition _ctrlText;
			private _oldX		= _oldPos select 0;
			private _oldY		= _oldPos select 1;
			private _oldWidth	= _oldPos select 2;
			private _oldHeight	= _oldPos select 3;

			_ctrlText ctrlSetPosition [_oldX,_oldY,_width,_height];
			_ctrlText ctrlCommit 0;
			
			uiSleep 5;
		} else {
			if (_doDebugOutput) then { systemChat "Player is NOT Zeus/Curator."; };
			uiSleep 15;
		};
	};
}
