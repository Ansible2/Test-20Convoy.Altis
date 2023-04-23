/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_handleDeadDriver_default

Description:
    The default function that runs when a driver is detected as dead in a vehicle convoy.
    This is not fired based off an event handler but rather a check in the onEachFrame for
     the convoy vehicles.
    The function will wait 4 seconds before affecting its behavior on the vehicle.
    
    If the previous driver was a player, and a player is in the vehicle, nothing will happen.
    If the previous driver was a player, and a player is NOT in the vehicle, an AI will take over
     driving the vehicle.
    If the previous driver was NOT a player, and a player is in the highest priority seat to
     be the new driver, nothing will happen.
    If the previous driver was NOT a player, and an AI is in the highest priority seat to
     be the new driver, they will be automatically moved into the driver seat.
    
    The priority of vehicle role in the order of who the next driver is:
        1. commander
        2. cargo
        3. turrets
        4. gunner

    This means commanders if present will be desired to move into the driver seat over
     all other vehicle roles.

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

#define WAIT_TIME 4

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_convoyHashMap",nil],
    ["_convoyLead",objNull,[objNull]]
]; 


if (_vehicle isEqualTo _convoyLead) exitWith {
    [_vehicle] call KISKA_fnc_convoyAdvanced_removeVehicle;
    
    private _newConvoyLead = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyLeader;
    if (isNull _newConvoyLead) then {
        [_convoyHashMap] call KISKA_fnc_convoyAdvanced_delete;

    } else {
        // There's no consistent way to know what the former lead's intended path is, so stop
	    [_newConvoyLead] call KISKA_fnc_convoyAdvanced_stopVehicle; 

    };
};


[{


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
private _preferredNewDriver_isPlayer = false;
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
        _preferredNewDriver_isPlayer = _unitIsPlayer;

        private _unitIsCommander = _unitPriority isEqualTo 3;
        private _isPriorityUnit = _unitIsCommander AND (!_driverWasPlayer) AND (!_unitIsPlayer);
        if (_isPriorityUnit) then { break };
    };
};

if (isNil "_preferredNewDriver" OR {_preferredNewDriver_isPlayer}) exitWith {};

[_currentDriver, _vehicle] remoteExecCall ["moveOut", _currentDriver];
[_preferredNewDriver, _vehicle] remoteExecCall ["moveOut", _preferredNewDriver];
[_preferredNewDriver, _vehicle] remoteExecCall ["moveInDriver", _preferredNewDriver];

_vehicle setVariable ["KISKA_convoyAdvanced_deadDriverBeingHandled",false];


nil
   
},_this,WAIT_TIME] call CBA_fnc_waitAndExecute;
