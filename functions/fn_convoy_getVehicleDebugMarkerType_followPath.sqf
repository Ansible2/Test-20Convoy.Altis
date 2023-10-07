/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_getVehicleDebugMarkerType_followPath

Description:
    Gets the 3d debug marker class name that will be used to mark waypoints for 
     a given vehicles path that have been completed.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the marker type of

Returns:
    <STRING> - The classsName used for the 3d debug marker of the follow path
     of the given convoy vehicle.

Examples:
    (begin example)
        private _followPathMarkerType = [
            _vehicle
        ] call KISKA_TEST_fnc_convoy_getVehicleDebugMarkerType_followPath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_getVehicleDebugMarkerType_followPath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable [
    "KISKA_convoy_debugMarkerType_followPath",
    "Sign_Arrow_Large_Cyan_F"
]
