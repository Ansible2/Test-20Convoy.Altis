/* ----------------------------------------------------------------------------
Function: KISKA_convoyAdvanced_handleVehicleKilled_default

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
scriptName "KISKA_convoyAdvanced_handleVehicleKilled_default";

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

if (_vehicle isEqualTo _convoyLead) exitWith {
    // convoy tries to drive around,
    // if the vehicles can't drive, then halt

	// stop convoy
	// remove current vehicle
	// change leader to next vehicle
    private _newConvoyLead = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyLeader;
    if (isNull _newConvoyLead) exitWith {};

	[_newConvoyLead] call KISKA_fnc_convoyAdvanced_stopVehicle;
};


// if vehicle is not convoy lead:
// vehicles should be able to drive around
/// the vehicle that was destroyed

// this means there will need to be some adjustment to their
/// drive path dynamically


// need to detect when vehicle dies
// vehicle may not be local to machine running convoy
// need to be able to call the same KISKA_convoyAdvanced_handleVehicleKilled function
// no matter who is local