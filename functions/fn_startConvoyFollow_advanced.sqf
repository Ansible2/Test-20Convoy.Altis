params ["_vics"];

private _leadVic = _vics select 0;
private _startingPoint = getPosATL _leadVic;

while { KISKA_doTheThing } do {
	{
		private _currentVehicle = _x;
        if (_currentVehicle isEqualTo _leadVic) then {continue};
        
        private _vehicleAhead = _vics param [_forEachIndex - 1, objNull];
		private _vehicleAheadPosition = getPosATL _vehicleAhead;

		private _currentVehicleDrivePath = _currentVehicle getVariable ["KISKA_convoyDrivePath",[]];
		private _currentVehiclePathCount = count _currentVehicleDrivePath;
		private _lastIndexInCurrentPath = (_currentVehiclePathCount - 1) max 0;
		private _previousDrivePosition = _currentVehicleDrivePath param [_lastIndexInCurrentPath,_vehicleAheadPosition];
		
		if (_currentVehicleDrivePath isEqualTo []) then {
			_currentVehicleDrivePath pushBack _vehicleAheadPosition;
			_currentVehicle getVariable ["KISKA_convoyDrivePath",_currentVehicleDrivePath];
		};

		// noone else behind in the convoy should move if the vehicle ahead has not moved a significant amount
		if (_vehicleAheadPosition vectorDistance _previousDrivePosition <= 5) then {break}; 
		
		

    } forEach _vics;

	sleep 2;
};
		// private _driver = driver _currentVehicle;