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
    3: _deadDriver <OBJECT> - The dead driver

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
    ["_deadDriver",objNull,[objNull]]
]; 


if (isNull _vehicle) exitWith {
    [
        [
            "null _vehicle was passed, _convoyHashMap is: ",
            _convoyHashMap
        ],
        false
    ] call KISKA_fnc_log;

    nil
};

if (isNil "_convoyHashMap") exitWith {
    [   
        [
            "nil _convoyHashMap was passed, _vehicle is: ",
            _vehicle
        ],
        false
    ] call KISKA_fnc_log;

    nil
};

if (isNil "_convoyHashMap") exitWith {
    [   
        [
            "nil _convoyHashMap was passed, _vehicle is: ",
            _vehicle
        ],
        false
    ] call KISKA_fnc_log;

    nil
};

if (isNull _deadDriver) exitWith {
    [
        [
            "null _deadDriver was passed, _vehicle is: ",
            _vehicle
        ],
        false
    ] call KISKA_fnc_log;

    nil
};


// TODO: complete
private _currentDriver = driver _vehicle;
if (_currentDriver isNotEqualTo _deadDriver) exitWith {};

private "_prefferedNewDriver";
private _prefferedNewDriver_isPlayer = false;
private _prefferedNewDriver_role = "";

// prioritize the same kind of unit that was in the driver seat
/// if the driver was a player, their replacement should ideally be a player
/// and vice-versa

// commander should be the priority 1 seat
/// then cargo
/// then turret
/// then gunner

(fullCrew _vehicle) apply {
    _x params ["_unit","_role","_index"];
    private _isPlayer = isPlayer _unit;


    if (_role == "commander") then {

    };


    if (_role == "gunner") then {

    };
    if (_role == "turret") then {

    };
    if (_role == "cargo") then {

    };
};

if (isNil "_prefferedNewDriver") exitWith {};

[_prefferedNewDriver,_vehicle] remoteExecCall ["moveOut",_prefferedNewDriver];
[_prefferedNewDriver,_vehicle] remoteExecCall ["moveInDriver",_prefferedNewDriver];


nil
