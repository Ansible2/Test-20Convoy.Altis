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
private _killedVehicle_drivePath = _killedVehicle getVariable ["KISKA_convoyAdvanced_drivePath",[]];
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
_vehicleThatWasBehind setVariable ["KISKA_convoyAdvanced_queuedPoints",[]];

private _killedVehicle_firstDrivePathPoint = _killedVehicle_drivePath param [0,[]];
if (_killedVehicle_firstDrivePathPoint isEqualTo []) exitWith {};


// TODO:

// stop the vehicle
/// keep queueing points
/// do not drive to those points or add to drivePath
// clear drive path
// clear queued path
// calc path to last queued point of killed vehicle
// define overall queued path as the calc'd path plus the points that were queued while the vehicle was stopped

// Waiting because using calculatePath too soon returns strange paths
[
    {
        params [
            "_vehicleThatWasBehind",
            "_killedVehicle_firstDrivePathPoint",
            "_killedVehicle_drivePath"
        ];

        // using "man" to calculatePath because vehicles will otherwise refuse to squeeze past vehicles in the road
        // other options will go completely around instead of driving past
        private _calculatePathAgent = calculatePath ["man","safe",getPosATLVisual _vehicleThatWasBehind,_killedVehicle_firstDrivePathPoint];
        _calculatePathAgent setVariable ["KISKA_convoyAdvanced_pathVehicle",_vehicleThatWasBehind];
        _calculatePathAgent setVariable ["KISKA_convoyAdvanced_killedVehicle_drivePath",_killedVehicle_drivePath];
        _calculatePathAgent addEventHandler ["PathCalculated", {
            params ["_calculatePathAgent","_path"];

            private _vehicleThatWasBehind = _calculatePathAgent getVariable ["KISKA_convoyAdvanced_pathVehicle",objNull];
            private _vehicleThatWasBehind_isStillInConvoy = !(isNil { _vehicleThatWasBehind getVariable "KISKA_convoyAdvanced_hashMap" });
            if ((alive _vehicleThatWasBehind) AND _vehicleThatWasBehind_isStillInConvoy) then {
                // set height
                _path apply {
                    _x set [2,0];
                };

                private _killedVehicle_drivePath = _calculatePathAgent getVariable ["KISKA_convoyAdvanced_killedVehicle_drivePath",[]];
                _path append _killedVehicle_drivePath;
                _vehicleThatWasBehind setVariable ["KISKA_convoyAdvanced_queuedPoints",_path];
                _vehicleThatWasBehind setVariable ["KISKA_convoyAdvanced_drivePath",[]];
                (driver _vehicleThatWasBehind) enableAI "path";

                // TODO: get all other vehicles behind to follow this path too
            };
        }];
    },
    [
        _vehicleThatWasBehind,
        _killedVehicle_firstDrivePathPoint,
        _killedVehicle_drivePath
    ],
    2
] call CBA_fnc_waitAndExecute;


// TODO: delete queued points with debug objects?
private _vehicleThatWasBehind_debugPath = _vehicleThatWasBehind getVariable ["KISKA_convoyAdvanced_debugPathObjects",[]];
_vehicleThatWasBehind setVariable ["KISKA_convoyAdvanced_debugPathObjects",[]];
_vehicleThatWasBehind_debugPath apply {
    deleteVehicle _x;
};
