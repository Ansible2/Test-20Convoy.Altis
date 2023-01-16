/* ----------------------------------------------------------------------------
Function: KISKA_fnc_startConvoyFollow_basic

Description:
    

Parameters:
    0: _convoyGroup <GROUP> - The convoy group which includes all drivers
    1: _convoyVehicles <OBJECT[]> - The vehicles in the convoy. This should be sorted in the order they will drive

Returns:
    

Examples:
    (begin example)
        [

        ] call KISKA_fnc_startConvoyFollow_basic;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_startConvoyFollow_basic";

if (!canSuspend) exitWith {
    ["Function should be run in scheduled environment, exiting to scheduled...",false] call KISKA_fnc_log;
    _this spawn KISKA_fnc_startConvoyFollow_basic;
};

params [
    ["_convoyGroup",grpNull,[grpNull]],
    ["_convoyVehicles",[],[[]]]
];


if (isNull _convoyGroup) exitWith {
    ["_convoyGroup was null",true] call KISKA_fnc_log;
    nil
};

if (_convoyVehicles isEqualTo []) exitWith {
    ["_convoyVehicles was empty array",true] call KISKA_fnc_log;
    nil
};

_convoyGroup setVariable ["KISKA_convoyDoBasicFollow",true];

while {_convoyGroup getVariable ["KISKA_convoyDoBasicFollow",false]} do {
    private _leader = leader _convoyGroup;
    private _followUpdates = [];

    {
        private _driver = driver _x;
        if (_driver isEqualTo _leader) then {continue};

        private _vehicleAhead = _convoyVehicles param [_forEachIndex - 1, objNull];
        private _convoySeperation = _convoyGroup getVariable ["KISKA_convoySeperation",30];
        private _maxAcceptedDistance = _convoySeperation * _forEachIndex;

        private _distanceToVehicleAhead = _x distance _vehicleAhead;
        if (_distanceToVehicleAhead > _maxAcceptedDistance) then {
            _followUpdates pushBack _driver;
            _x forceFollowRoad false;
            _x setVariable ["KISKA_convoy_toldToFollow",true];
            continue;
        };

        if (_x getVariable ["KISKA_convoy_toldToFollow",false] AND (isOnRoad _x)) then {
            _x setVariable ["KISKA_convoy_toldToFollow",false];
            _x forceFollowRoad true;
        };

    } forEach _convoyVehicles;

    if (_followUpdates isNotEqualTo []) then {
        _followUpdates doFollow _leader;
    };

    sleep 2;
};
