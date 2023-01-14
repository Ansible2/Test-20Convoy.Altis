// each vehicle will move to a position behind the vehicle in front of them

private _vics = [
	// vic1,
	vic2,
	vic3
];

(driver vic1) move (getPosATL movePos);

KISKA_driveArray = [];
KISKA_doRecord = true;
[] spawn {
	while { KISKA_doRecord } do {
		private _speed = speed vic1;
		if (_speed isEqualTo 0) then {continue};

		private _currentPosition = getPosATL vic1;
		// _currentPosition pushBack _speed;
		KISKA_driveArray pushBack _currentPosition;

		sleep 0.5;
	};
};

sleep 5;

waitUntil {count KISKA_driveArray > 3};

hint str KISKA_driveArray;

_vics apply {
	[
		_x,
		KISKA_driveArray
	] call KISKA_fnc_playDrivePath;
};
