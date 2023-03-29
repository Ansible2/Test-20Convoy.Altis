/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_handleDeadDriver_default

Description:
    The default function that runs when a driver is detected as dead in a vehicle convoy.

    This is not fired based off an event handler but rather a check in the onEachFrame for
     the convoy vehicles.

Parameters:
    0: _vehicle <OBJECT> - The vehicle that has a dead driver
    1: _convoyHashMap <HASHMAP> - The hashmap used for the convoy
    2: _convoyLead <OBJECT> - The lead vehicle of the convoy
    3: _vehicleDriver <OBJECT> - The dead driver

Returns:
    NOTHING

Examples:
    (begin example)
        SHOULD NOT BE CALLED DIRECTLY
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_handleDeadDriver_default";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_convoyHashMap",nil],
    ["_convoyLead",objNull,[objNull]],
    ["_vehicleDriver",objNull,[objNull]]
]; 


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

if (isNull _vehicleDriver) exitWith {
    [
        [
            "null _vehicleDriver was passed, _vehicle is: ",
            _vehicle
        ],
        true
    ] call KISKA_fnc_log;

    nil
};


// TODO: complete

if (isPlayer _vehicleDriver) exitWith {};

private "_prefferedNewDriver";
(fullCrew _vehicle) apply {

};