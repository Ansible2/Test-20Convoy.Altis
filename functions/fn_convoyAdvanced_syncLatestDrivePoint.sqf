/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_syncLatestDrivePoint

Description:
    Ensures all vehicles in the convoy have the latest drive path point from the
	 convoy lead as the last index of their drive path.

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy's hashmap

Returns:
    NOTHING

Examples:
    (begin example)
        [ConvoyHashMap] call KISKA_fnc_convoyAdvanced_syncLatestDrivePoint;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_syncLatestDrivePoint";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};


params ["_convoyHashMap"];

private _latestPointToAdd = _convoyHashMap get "_latestPointOnPath";

private _convoyVehicles = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;
_convoyVehicles apply {
	private _lastAddedPoint = _x getVariable "KISKA_convoyAdvanced_lastAddedPoint";
	if (_lastAddedPoint isEqualTo _latestPointToAdd) then { continue };

	// TODO: function
	_x setVariable ["KISKA_convoyAdvanced_lastAddedPoint",_latestPointToAdd];

	if ([_x] call KISKA_fnc_convoyAdvanced_isVehicleInDebug) then {
		private _debugObjectType = _x getVariable [
			// TODO: adjsut name of variable to not be "queued"
			"KISKA_convoyAdvanced_debugMarkerType_queuedPoint",
			"Sign_Arrow_Large_Cyan_F"
		];
		private _debugObject = createVehicle [_debugObjectType, _latestPointToAdd, [], 0, "CAN_COLLIDE"];

		private _currentVehicle_debugDrivePathObjects = _x getVariable "KISKA_convoyAdvanced_debug_followPathObjects";
		_currentVehicle_debugDrivePathObjects pushBack _debugObject;
	};

	private _indexInserted = _currentVehicle_drivePath pushBack _latestPointToAdd;
	if (_indexInserted >= 1) then {
		_x setDriveOnPath _currentVehicle_drivePath;
	};

};