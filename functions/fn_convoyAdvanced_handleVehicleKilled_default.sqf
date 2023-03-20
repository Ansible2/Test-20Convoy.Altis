/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_handleVehicleKilled_default

Description:
	The default behaviour that happens when a vehicle in the convoy dies.

Parameters:
    0: _killedVehicle <OBJECT> - The vehicle that died
    1: _convoyHashMap <HASHMAP> - The hashmap used for the convoy
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
    ["_killedVehicle",objNull,[objNull]],
    ["_convoyHashMap",nil],
    ["_convoyLead",objNull,[objNull]]
];

/* ----------------------------------------------------------------------------
	Parameter check
---------------------------------------------------------------------------- */
if (isNull _killedVehicle) exitWith {
    [
        [
            "null _killedVehicle was passed, _convoyHashMap is: ",
            _convoyHashMap
        ],
        true
    ] call KISKA_fnc_log;

    nil
};

if (isNil "_convoyHashMap") exitWith {
    [   
        [
            "nil _convoyHashMap was passed, _killedVehicle is: ",
            _killedVehicle
        ],
        true
    ] call KISKA_fnc_log;

    nil
};

if (isNull _convoyLead) exitWith {
    [   
        [
            "null _convoyLead was passed, _killedVehicle is: ",
            _killedVehicle,
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
private _killedVehicle_drivePath = [_killedVehicle] call KISKA_fnc_convoyAdvanced_getVehicleDrivePath;
[_killedVehicle] call KISKA_fnc_convoyAdvanced_removeVehicle;

private _vehicleIndex = [_killedVehicle] call KISKA_fnc_convoyAdvanced_getVehicleIndex;
private _newConvoyLead = [_convoyHashMap] call KISKA_fnc_convoyAdvanced_getConvoyLeader;
if (_killedVehicle isEqualTo _convoyLead) exitWith {
    if (isNull _newConvoyLead) exitWith {};

    // There's no consistent way to know what the former lead's intended path is, so stop
	[_newConvoyLead] call KISKA_fnc_convoyAdvanced_stopVehicle;
};


/* ---------------------------------
	Getting the rear vehicle to move to the lead vehicle
--------------------------------- */
private _vehicleThatWasBehind = [_convoyHashMap, _vehicleIndex] call KISKA_fnc_convoyAdvanced_getVehicleAtIndex;
[_vehicleThatWasBehind] call KISKA_fnc_convoyAdvanced_stopVehicle;
[_vehicleThatWasBehind, false] call KISKA_fnc_convoyAdvanced_setVehicleDoDriveOnPath;

// push to the right by default
private _pushToTheSideVelocity = 10;
private _killedVehicle_position = getPosWorldVisual _killedVehicle;
for "_i" from 1 to 25 do { 
    private _positionLeft = AGLToASL (_killedVehicle getRelPos [_i,270]);
    private _objectsAreOnTheLeft = (lineIntersectsObjs [_killedVehicle_position, _positionLeft, _killedVehicle, objNull,false,32]) isNotEqualTo [];
    if (_objectsAreOnTheLeft) then { break };
    
    private _positionRight = AGLToASL (_killedVehicle getRelPos [_i,90]);
    private _objectsAreOnTheRight = (lineIntersectsObjs [_killedVehicle_position, _positionRight, _killedVehicle, objNull,false,32]) isNotEqualTo [];
    if (_objectsAreOnTheRight) then {
        // push to the left
        _pushToTheSideVelocity = -10; 
        break 
    };
};


// shove vehicle to the side because AI drivers can't drive past consistently
[_killedVehicle, [_pushToTheSideVelocity,0,2]] remoteExecCall ["setVelocityModelSpace", _killedVehicle];


// Waiting because using calculatePath too soon returns strange paths
[
    {
        params [
            "_vehicleThatWasBehind",
            "_killedVehicle_firstDrivePathPoint",
            "_killedVehicle_drivePath",
            "_killedVehicle"
        ];

        // adjust mass so that a vehicle can push the dead one out of the way
        // in case it runs into the dead one
        [
            _killedVehicle, 
            ((getMass _vehicleThatWasBehind) / 2) 
        ] remoteExecCall ["setMass",_killedVehicle];


        private _driver = driver _vehicleThatWasBehind;
        [_driver,"path"] remoteExecCall ["enableAI",_driver];

        [_vehicleThatWasBehind, true] call KISKA_fnc_convoyAdvanced_setVehicleDoDriveOnPath;
    },
    [
        _vehicleThatWasBehind,
        _killedVehicle_firstDrivePathPoint,
        _killedVehicle_drivePath,
        _killedVehicle
    ],
    2
] call CBA_fnc_waitAndExecute;


nil
