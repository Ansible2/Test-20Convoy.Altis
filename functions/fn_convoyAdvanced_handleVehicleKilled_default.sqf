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

private _vehicleIndex = [_killedVehicle] call KISKA_convoyAdvanced_getVehicleIndex;
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
[_vehicleThatWasBehind, []] call KISKA_fnc_convoyAdvanced_setVehicleQueuedPoints;

private _killedVehicle_firstDrivePathPoint = _killedVehicle_drivePath param [0,[]];
if (_killedVehicle_firstDrivePathPoint isEqualTo []) exitWith {};

// shove vehicle to the side because AI drivers can't drive past consistently
[_killedVehicle, [-10,0,0]] remoteExecCall ["setVelocityModelSpace", _killedVehicle];


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

        // using "man" to calculatePath because vehicles will otherwise refuse to squeeze past vehicles in the road
        // other options will generate paths that go completely around (on another road) instead of driving past
        private _calculatePathAgent = calculatePath ["man","safe",getPosATLVisual _vehicleThatWasBehind,_killedVehicle_firstDrivePathPoint];
        _calculatePathAgent setVariable ["KISKA_convoyAdvanced_pathVehicle",_vehicleThatWasBehind];
        _calculatePathAgent setVariable ["KISKA_convoyAdvanced_killedVehicle_drivePath",_killedVehicle_drivePath];
        _calculatePathAgent addEventHandler ["PathCalculated", {
            params ["_calculatePathAgent","_path"];

            private _vehicleThatWasBehind = _calculatePathAgent getVariable ["KISKA_convoyAdvanced_pathVehicle",objNull];
            private _vehicleThatWasBehind_isStillInConvoy = !(isNil { _vehicleThatWasBehind getVariable "KISKA_convoyAdvanced_hashMap" });
            if ((alive _vehicleThatWasBehind) AND _vehicleThatWasBehind_isStillInConvoy) then {
                // set height of _path points to be 0 (ATL)
                _path apply {
                    _x set [2,0];
                };

                private _killedVehicle_drivePath = _calculatePathAgent getVariable ["KISKA_convoyAdvanced_killedVehicle_drivePath",[]];
                _path append _killedVehicle_drivePath;

                private _queuedPathSinceStop = [_vehicleThatWasBehind] call KISKA_fnc_convoyAdvanced_getVehicleQueuedPoints;
                _path append _queuedPathSinceStop;
                
                [_vehicleThatWasBehind, _path] call KISKA_fnc_convoyAdvanced_setVehicleQueuedPoints;
                [_vehicleThatWasBehind] call KISKA_fnc_convoyAdvanced_clearVehicleDrivePath;
                [_vehicleThatWasBehind, true] call KISKA_fnc_convoyAdvanced_clearVehicleDebugFollowPath;
                [_vehicleThatWasBehind, true] call KISKA_fnc_convoyAdvanced_setVehicleDoDriveOnPath;

                private _driver = driver _vehicleThatWasBehind;
                [_driver,"path"] remoteExecCall ["enableAI",_driver];

                private _convoyHashMap = [_vehicleThatWasBehind] call KISKA_fnc_convoyAdvanced_getConvoyHashMapFromVehicle;
                private _vehicleThatWasBehind_index = [_vehicleThatWasBehind] call KISKA_fnc_convoyAdvanced_getVehicleIndex;
                private _vehiclesBehind = [
                    _convoyHashMap,
                    _vehicleThatWasBehind_index - 1
                ] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;

                // TODO: get all other vehicles behind to follow this path too
                _vehiclesBehind apply {

                };
            };
        }];
    },
    [
        _vehicleThatWasBehind,
        _killedVehicle_firstDrivePathPoint,
        _killedVehicle_drivePath,
        _killedVehicle
    ],
    2
] call CBA_fnc_waitAndExecute;


[_vehicleThatWasBehind,true] call KISKA_fnc_convoyAdvanced_clearVehicleDebugFollowPath;
