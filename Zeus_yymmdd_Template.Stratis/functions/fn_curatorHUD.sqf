
null=[]spawn {
	disableSerialization;

	if (isServer) exitWith {};

	while {true} do {
		// Check if is Zeus/CuratorHUDLayer
		if (side player == sideLogic) then {
			systemChat "Player is Zeus/Curator.";
		} else {
			systemChat "Player is NOT Zeus/Curator.";
			uiSleep 15;
		};
	
		private _id = ["CuratorHUDLayer"] call BIS_fnc_rscLayer;
		_id cutRsc ["RscTeamHealthHUD", "PLAIN"];

		private _name = name player;
		private _time = time;

		waitUntil {!isNull (uiNameSpace getVariable "ZO_RscTeamHealthHUD")};
		systemChat "HUD initialized.";
		_display = uiNameSpace getVariable "ZO_RscTeamHealthHUD";
		_ctrlText = _display displayCtrl 4591;
		systemChat format ["_ctrlText = %1.", _ctrlText];

		private _headlessClients = entities "HeadlessClient_F";
		private _humanPlayers = allPlayers - _headlessClients;
		systemChat format ["We currently have %1 human players and %2 HCs.", count _humanPlayers, count _headlessClients];

		private _allGroupsWithPlayers = [];
		{_allGroupsWithPlayers pushBackUnique group _x} forEach _humanPlayers;
		systemChat format ["We currently have %1 groups with players.", count _allGroupsWithPlayers];

		private _showLeader = true;

		private _groupsOutputArray = [];
		{
			private _group = _x;
			private _groupName 				= groupId _group;
			systemChat format ["On group %1.", _groupName];
			private _groupLeader 		= leader _group;
			private _groupLeaderName	= [_groupLeader] call BIS_fnc_getName;
			private _groupPlayers 		= units _group;
			private _groupPlayerCount	= count _groupPlayers;
			private _playersHealthyArray = [];
			private _playersDeadArray = [];
			private _playersOutputArray = [];
			
			{
				private _playerName 	= [_x] call BIS_fnc_getName;
				systemChat format ["On player %1.", _playerName];
				private _isLeader			= _x == _groupLeader;
				private _leaderString		= if (_isLeader) then [ { " (L)" }, { "" } ];
				private _lifeState 			= lifeState _x;
				private _isHealthy			= _lifeState == "HEALTHY";
				if (_isHealthy) then {
					_playersHealthyArray pushBack _playerName;
				};
				if (_lifeState == "DEAD" || (!alive _x)) then {
					_playersDeadArray pushBack _playerName;
				};
				private _playersText		= format ["%1%2 (%3)", _playerName, _leaderString, _lifeState];
				_playersOutputArray pushBack _playersText;
			} forEach _groupPlayers;
			
			private _groupPlayersHealthyCount = count _playersHealthyArray;
			private _groupPlayersDeadCount = count _playersDeadArray;
			private _color = "#000000";
			if (_groupPlayersHealthyCount == _groupPlayerCount) then {
				_color = "#0A9B00";
			} else {
				if ((_groupPlayersHealthyCount > 0) && (_groupPlayersHealthyCount <= (0.5 * _groupPlayerCount))) then {
					_color = "#D97E00";
				} else {
					_color = "#D40004";
				};
			};
			
			private _deadString = if (_groupPlayersDeadCount > 0) then [ { format [" (Dead: %1)", _groupPlayersDeadCount] }, { "" } ];
			private _groupText = format ["<t size='1.0' color='%1'>%2: %3/%4%5</t>", _color, _groupName, _groupPlayersHealthyCount, _groupPlayerCount, _deadString];
			_groupsOutputArray pushBack _groupText;
			
			systemChat format ["Group %1 (L: %2): %3", _groupName, _groupLeaderName, _playersOutputArray joinString ", "];
		} forEach (_allGroupsWithPlayers);

		private _finalText = _groupsOutputArray joinString ", ";

		_ctrlText ctrlSetStructuredText parseText _finalText;
		_ctrlText ctrlSetBackgroundColor [0,0,0,0.5];

		// Fix width/height
		private _width = ctrlTextWidth _ctrlText;
		private _height = ctrlTextHeight _ctrlText;
		systemChat format ["W = %1, H = %2", _width, _height];
		private _oldPos = ctrlPosition _ctrlText;
		private _oldX		= _oldPos select 0;
		private _oldY		= _oldPos select 1;
		private _oldWidth	= _oldPos select 2;
		private _oldHeight	= _oldPos select 3;

		_ctrlText ctrlSetPosition [_oldX,_oldY,_width,_height];
		_ctrlText ctrlCommit 0;
		
		uiSleep 5;
	};
}
