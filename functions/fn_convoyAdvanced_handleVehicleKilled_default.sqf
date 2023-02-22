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
private _newConvoyLead = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyLeader;
if (_vehicle isEqualTo _convoyLead) exitWith {
    if (isNull _newConvoyLead) exitWith {};

    // There's no consistent way to know what the former lead's intended path is, so stop
	[_newConvoyLead] call KISKA_fnc_convoyAdvanced_stopVehicle;
};


private _moveToPosition = getPosATLVisual _newConvoyLead;

_vehicle move _moveToPosition;


// if vehicle is not convoy lead:
// vehicles should be able to drive around
/// the vehicle that was destroyed

// this means there will need to be some adjustment to their
/// drive path dynamically


// need to detect when vehicle dies
// vehicle may not be local to machine running convoy
// need to be able to call the same KISKA_convoyAdvanced_handleVehicleKilled function
// no matter who is local