params ["_vics"];

private _leadVic = _vics select 0;
_vics apply {
	if (_x isEqualTo _leadVic) then {continue};

	doStop (driver _x);
	_x engineOn true;
};

sleep 1;

KISKA_doTheThing = true;
private _loop = 0;
while { KISKA_doTheThing } do {
	{
		private _currentVehicle = _x;
        if (_currentVehicle isEqualTo _leadVic) then {continue};
        
        private _vehicleAhead = _vics param [_forEachIndex - 1, objNull];
		private _vehicleAheadPosition = getPosATL _vehicleAhead;

		private _currentVehicleDrivePath = _currentVehicle getVariable ["KISKA_convoyDrivePath",[]];
		
		if (_currentVehicleDrivePath isEqualTo []) then {
			_currentVehicleDrivePath pushBack _vehicleAheadPosition;
			_currentVehicle setVariable ["KISKA_convoyDrivePath",_currentVehicleDrivePath];
		};

		private _currentVehiclePathCount = count _currentVehicleDrivePath;
		private _lastIndexInCurrentPath = (_currentVehiclePathCount - 1) max 0;
		private _lastestPointToDriveTo = _currentVehicleDrivePath param [_lastIndexInCurrentPath,_vehicleAheadPosition];
		private _bufferDistanceToNextVehicle = (sizeOf (typeOf _vehicleAhead)) + 2;
		// noone else behind in the convoy should move if the vehicle ahead has not moved a significant amount
		if (_vehicleAheadPosition vectorDistance _lastestPointToDriveTo <= _bufferDistanceToNextVehicle) then {
			hint str ["break at distance",_loop];
			break;
		};

		hint str ["passed distance",_loop];
		
		private _currentVehiclePosition = getPosATLVisual _currentVehicle;
		private _deleteStartIndex = -1;
		private _numberToDelete = 0;
		{
			private _withinOneMeter = (_currentVehiclePosition vectorDistance _x) <= 1;

			if !(_withinOneMeter) then {break};
			_numberToDelete = _numberToDelete + 1;

			if (_deleteStartIndex isNotEqualTo -1) then {continue};
			_deleteStartIndex = _forEachIndex;

		} forEach _currentVehicleDrivePath;


		if (_deleteStartIndex >= 0) then {
			_currentVehicleDrivePath deleteRange [_deleteStartIndex,_numberToDelete];
		};


		private _indexInserted = _currentVehicleDrivePath pushBack _vehicleAheadPosition;

		if (_indexInserted >= 1) then {
			hint str [_x, _currentVehicleDrivePath,_loop];
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

	sleep 0.1;
	_loop = _loop + 1;
};
		// private _driver = driver _currentVehicle;