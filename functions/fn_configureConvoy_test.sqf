/* ----------------------------------------------------------------------------
Function: KISKA_fnc_configureConvoy

Description:
    Creates several convoy vehicles and/or configures their groups to be ready
     to act as a convoy.

Parameters:
    0: _side <SIDE> - What side this convoy is on
    1: _spawnInfo <ARRAY> - An array of either or both option types:
        - Option 1: <ARRAY> [spawnPosition (positionATL or OBJECT), spawnDirection (NUMBER), className (STRING)] -
            Vehicle will be created from from the class name and spawned at the given position
            using KISKA_fnc_spawnVehicle
        - Option 2: <OBJECT> - Must be a land vehicle with a driver

        These ideally will be in sequential order of how they line up to the lead vehicle
        which is the 0 index vehicle

    2: _handleBehaviour <BOOL> - Whether or not to adjust the convoy drivers group's 
        behaviour and AI features in order to make the convoy more reliably calm.

Returns:
    <ARRAY> -
        0: <GROUP> - The convoy group which includes all drivers
        1: <ARRAY> - The vehicles in the convoy (lead vehicle is index 0)

Examples:
    (begin example)
        [
            BLUFOR,
            [
                leadVehicle,
                ["someVehicleClassToSpawn",myPos,-1]
            ]
        ] call KISKA_fnc_configureConvoy;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_configureConvoy";

params [
    ["_side",OPFOR,[sideUnknown]],
    ["_spawnInfo",[],[[]]],
    ["_handleBehaviour",true,[true]]
];

if (_spawnInfo isEqualTo []) exitWith {
    ["_spawnInfo is empty!",true] call KIKSA_fnc_log;
    []
};


private _convoyGroup = createGroup _side;
private _vehicles = [];
private _drivers = [];
_spawnInfo apply {
    if (_x isEqualType objNull) then {
        private _driver = driver _x;
        if (alive _driver) then {
            _drivers pushBack _driver;
            [_driver] joinSilent _convoyGroup;
            _Vehicles pushBackUnique _x;
            [_x, _driver] remoteExec ["setEffectiveCommander",0];
        };

        continue;
    };


    private _vehicleInfo = [
        _x select 0,
        _x select 1,
        _x select 2,
        _convoyGroup
    ] call KISKA_fnc_spawnVehicle;

    private _vehicle = _vehicleInfo select 0;
    private _driver = driver _vehicle;
    _drivers pushBack _driver;
    [_vehicle, _driver] remoteExec ["setEffectiveCommander",0];

    _vehicles pushBack _vehicle;
};


private _convoyInfo = [
    _convoyGroup,
    _vehicles
];
if !(_handleBehaviour) exitWith {_convoyInfo};


_convoyGroup setFormation "COLUMN";
_convoyGroup setBehaviourStrong "SAFE";
_convoyGroup setCombatMode "BLUE";
_drivers apply {
    [_x,"AUTOCOMBAT"] remoteExec ["disableAI",_x]; 
    [_x,"TARGET"] remoteExec ["disableAI",_x]; 
};


_convoyInfo
