scriptName "KISKA_fnc_startConvoyFollowAdvanced";

params ["_vics"];

private _leadVic = _vics select 0;
_vics apply {
	if (_x isEqualTo _leadVic) then {continue};

	doStop (driver _x);
	_x engineOn true;
};

sleep 1;

KISKA_doTheThing = true;
// todo: should add speed to the points probably

[
	{
		params ["_args","_handle"];
		_args params ["_vics","_leadVic"];
		{
			private _currentVehicle = _x;
			if (_currentVehicle isEqualTo _leadVic) then {continue};
			


			private _vehicleAhead = _vics param [_forEachIndex - 1, objNull];
			private _vehicleAheadPosition = getPosATL _vehicleAhead;
			private _currentVehicleDrivePath = _currentVehicle getVariable ["KISKA_convoyDrivePath",[]];
			private _currentVehicleDrivePath_debug = _currentVehicle getVariable ["KISKA_convoyDrivePath_debug",[]];
			if (_currentVehicleDrivePath isEqualTo []) then {
				_currentVehicleDrivePath pushBack _vehicleAheadPosition;
				private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _vehicleAheadPosition, [], 0, "CAN_COLLIDE"];
				_currentVehicleDrivePath_debug pushBack _debugObject;

				_currentVehicle setVariable ["KISKA_convoyDrivePath",_currentVehicleDrivePath];
				_currentVehicle setVariable ["KISKA_convoyDrivePath_debug",_currentVehicleDrivePath_debug];
			};



			private _currentVehiclePosition = getPosATLVisual _currentVehicle;
			private _deleteStartIndex = -1;
			private _numberToDelete = 0;
			{
				// TODO, adjusting this too low causes the points to not be deleted despite it appearing that vehicles are within the radius
				private _withinOneMeter = (_currentVehiclePosition distance _x) <= 5;

				if !(_withinOneMeter) then {break};
				_numberToDelete = _numberToDelete + 1;
				// hint str [(_currentVehiclePosition distance _x), _numberToDelete];

				if (_deleteStartIndex isNotEqualTo -1) then {continue};
				_deleteStartIndex = _forEachIndex;

			} forEach _currentVehicleDrivePath;

			// first point is not marked with marker
			if (_deleteStartIndex >= 0) then {
				// [["_deleteStartIndex: ",_deleteStartIndex," _numberToDelete: ",_numberToDelete]] call KISKA_fnc_log;
				_currentVehicleDrivePath deleteRange [_deleteStartIndex,_numberToDelete];
				private _lastIndexToDelete = _deleteStartIndex + (_numberToDelete - 1);
				createVehicle ["Sign_Arrow_Large_blue_F", _currentVehiclePosition, [], 0, "CAN_COLLIDE"];

				for "_i" from _deleteStartIndex to _lastIndexToDelete do { 
					deleteVehicle (_currentVehicleDrivePath_debug select _i);
				};
				_currentVehicleDrivePath_debug deleteRange [_deleteStartIndex,_numberToDelete];
			};



			// noone else behind in the convoy should move if the vehicle ahead has not moved a significant amount
			private _currentVehiclePathCount = count _currentVehicleDrivePath;
			private _lastIndexInCurrentPath = (_currentVehiclePathCount - 1) max 0;
			private _lastestPointToDriveTo = _currentVehicleDrivePath param [_lastIndexInCurrentPath,_vehicleAheadPosition];
			private _bufferDistanceToNextVehicle = (sizeOf (typeOf _vehicleAhead)) + 2;
			private _distanceToLastDrivePoint = _vehicleAheadPosition distance _lastestPointToDriveTo;
			private _vehicleAheadHasNotMovedEnough = _distanceToLastDrivePoint <= _bufferDistanceToNextVehicle;
			if (_vehicleAheadHasNotMovedEnough) then {continue};

			
			
			private _indexInserted = _currentVehicleDrivePath pushBack _vehicleAheadPosition;
			private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _vehicleAheadPosition, [], 0, "CAN_COLLIDE"];
			_currentVehicleDrivePath_debug pushBack _debugObject;
			hint str _currentVehicleDrivePath;
			if (_indexInserted >= 1) then {
				_currentVehicle setDriveOnPath _currentVehicleDrivePath;
				continue;
			};


			// if (_vehicleAheadPosition isNotEqualTo _lastestPointToDriveTo) then {
			// 	_currentVehicleDrivePath pushBack _lastestPointToDriveTo;
			// 	hint str [_x, _currentVehicleDrivePath,0];
			// 	_currentVehicle setDriveOnPath _currentVehicleDrivePath;
			// 	continue;
			// };

			// _currentVehicleDrivePath = [_vehicleAheadPosition];
			// _currentVehicle setVariable ["KISKA_convoyDrivePath",_currentVehicleDrivePath];
			// hint str [_x, _currentVehicleDrivePath,1];
			// _currentVehicle setDriveOnPath _currentVehicleDrivePath;

		} forEach _vics;
	},
	0.05,
	[_vics,_leadVic]
] call CBA_fnc_addPerFrameHandler