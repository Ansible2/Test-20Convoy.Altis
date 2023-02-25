/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_handleVehicleKilled_default

Description:
	The default behaviour that happens when a vehicle in the convoy dies.

Parameters:
    0: _vehicle <OBJECT> - The vehicle that died
    1: _convoyHashMap <OBJECT> - The hashmap used for the convoy
    2: _convoyLead <OBJECT> - The lead vehicle of the convoy

Returns:
    NOTHING

Examples:
    (begin example)
        SHOULD NOT BE CALLED DIRECTLY
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_handleVehicleKilled_default";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_convoyHashMap",nil],
    ["_convoyLead",objNull,[objNull]]
];

/* ----------------------------------------------------------------------------
	Parameter check
---------------------------------------------------------------------------- */
if (isNull _vehicle) exitWith {
    [
        [
            "null _vehicle was passed, _convoyHashMap is: ",
            _convoyHashMap
        ],
        true
    ] call KISKA_fnc_log;

    nil
};

if (isNil "_convoyHashMap") exitWith {
    [   
        [
            "nil _convoyHashMap was passed, _vehicle is: ",
            _vehicle
        ],
        true
    ] call KISKA_fnc_log;

    nil
};

if (isNull _convoyLead) exitWith {
    [   
        [
            "null _convoyLead was passed, _vehicle is: ",
            _vehicle,
			" and _convoyHashMap is: ",
			_convoyHashMap
        ],
        true
    ] call KISKA_fnc_log;

    nil
};


/* ----------------------------------------------------------------------------
	Logic
---------------------------------------------------------------------------- */
[_vehicle] call KISKA_fnc_convoyAdvanced_removeVehicle;
private _vehicleIndex = [_vehicle] call KISKA_convoyAdvanced_getVehicleIndex;
private _newConvoyLead = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyLeader;
if (_vehicle isEqualTo _convoyLead) exitWith {
    if (isNull _newConvoyLead) exitWith {};

    // There's no consistent way to know what the former lead's intended path is, so stop
	[_newConvoyLead] call KISKA_fnc_convoyAdvanced_stopVehicle;
};


private _vehicleThatWasBehind = [_convoyHashMap, _vehicleIndex] call KISKA_fnc_convoyAdvanced_getVehicleAtIndex;
private _moveToPosition = getPosATLVisual _newConvoyLead;
_vehicleThatWasBehind move _moveToPosition;
[_vehicleThatWasBehind,_moveToPosition] call KISKA_fnc_convoyAdvanced_setDynamicMovePoint;
// Two paths
// 1. completely delete the current drive path and simply tell the vehicle to move to the 
/// new leader's current position
// 2. try to delete just the necessary points and then have the vehicle resume from the
/// the last point that would make sense

// Ultimately, this amounts to giving the vehicle a new point they need to move to
// once they are close enough to this new point, consider it complete and then
// they can resume following the drive path
_vehicleThatWasBehind setVariable ["KISKA_convoyAdvanced_drivePath",[]];
_vehicleThatWasBehind setVariable ["KISKA_convoyAdvanced_queuedPoints",[]];
// TODO: delete queued points with debug objects?
private _vehicleThatWasBehind_debugPath = _vehicleThatWasBehind getVariable ["KISKA_convoyAdvanced_debugPathObjects",[]];
_vehicleThatWasBehind_debugPath apply {
    deleteVehicle _x;
};
