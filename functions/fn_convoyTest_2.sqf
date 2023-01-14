// each vehicle will move to a position behind the vehicle in front of them

private _vics = [
	vic1,
	vic2,
	vic3
];

{
	private _driver = driver _x;
	if (_forEachIndex isNotEqualTo 0) then {
		private _vehicleBehind = _vics param [_forEachIndex + 1,objNull];
		_x setVariable ["vehicleAhead",_vehicleAhead];
	};

} forEach _vics;
