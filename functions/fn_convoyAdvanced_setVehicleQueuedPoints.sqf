/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_setVehicleQueuedPoints

Description:
	Sets a given convoy vehicle's queued points. Queued points are ATL positions that 
	 that the vehicle will attempt to drive (in the order provided). These positions
	 have not been added to a vehicle's drive path, but will be the following frame.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to set the queued points of
    1: _queuedPoints <PositionATL[]> - The array of ATL positions to set to
    2: _append <BOOL> - By default the `_queuedPoints` will overwrite the existing array
		so that there IS a refernce change for the array of queued points, you can choose
		to simply append to the existing array when this is `true`.

Returns:
    NOTHING

Examples:
    (begin example)
		// overwrite array entirely
		[_vehicle,_myPointsToQueue] call KISKA_fnc_convoyAdvanced_setVehicleQueuedPoints;
    (end)

    (begin example)
		// append to current queued list
		[_vehicle,_myPointsToQueue,true] call KISKA_fnc_convoyAdvanced_setVehicleQueuedPoints;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_setVehicleQueuedPoints";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_queuedPoints",[],[[]]],
    ["_append",false,[true]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null"] call KISKA_fnc_log;
    nil
};


if (!_append) exitWith {
	_vehicle setVariable ["KISKA_convoyAdvanced_queuedPoints",_queuedPoints];
};


private _currentQueuedPoints = _vehicle getVariable ["KISKA_convoyAdvanced_queuedPoints",[]];
_vehicle setVariable ["KISKA_convoyAdvanced_queuedPoints",_currentQueuedPoints append _queuedPoints];
