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


private _currentDriver = driver _vehicle;
if (_currentDriver isNotEqualTo _deadDriver) exitWith {};

private _driverWasPlayer = isPlayer [_deadDriver];
private "_preferredNewDriver";
private _preferredNewDriver_priority = -1;
private _rolePriorityHashMap = createHashMapFromArray [
    ["commander",3],
    ["cargo",2],
    ["turret",1],
    ["gunner",0]
];

(fullCrew _vehicle) apply {
    _x params ["_unit","_role","_index"];
    _role = toLowerANSI _role;
    private _unitIsPlayer = isPlayer _unit;

    // always want a player driver to not be replaced with an AI 
    // if there is another player in the vehicle
    if (_driverWasPlayer AND _unitIsPlayer) then {
        _preferredNewDriver = nil;
        break 
    };

    private _unitPriority = _rolePriorityHashMap getOrDefault [_role,-1];
    if (_preferredNewDriver_priority < _unitPriority) then {
        _preferredNewDriver_priority = _unitPriority;
        _preferredNewDriver = _unit;

        private _unitIsCommander = _unitPriority isEqualTo 3;
        private _isPriorityUnit = _unitIsCommander AND (!_driverWasPlayer) AND (!_unitIsPlayer);
        if (_isPriorityUnit) then { break };
    };
};
if (isNil "_preferredNewDriver") exitWith {};

// TODO: remoteExec having errors
// [_currentDriver,_vehicle] remoteExecCall ["moveOut",_currentDriver];
// [_prefferedNewDriver,_vehicle] remoteExecCall ["moveOut",_prefferedNewDriver];
// [_prefferedNewDriver,_vehicle] remoteExecCall ["moveInDriver",_prefferedNewDriver];

// TODO: _preferredNewDriver is not being moved out of vehice????
_currentDriver moveOut _vehicle;
_prefferedNewDriver moveOut _vehicle;
_prefferedNewDriver moveInDriver _vehicle;
_vehicle setVariable ["KISKA_convoyAdvanced_deadDriverChecked",false];

// hint str [_preferredNewDriver,_vehicle];
// hint str (driver _vehicle);


nil
