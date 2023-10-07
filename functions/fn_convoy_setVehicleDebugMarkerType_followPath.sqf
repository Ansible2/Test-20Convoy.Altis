/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_setVehicleDebugMarkerType_followPath

Description:
    Sets the 3d debug marker class name that will be used to mark waypoints for 
     a given vehicles path that have not been completed.
         
Parameters:
    0: _vehicle <OBJECT> - The vehicle to set the marker type of
    1: _type <STRING> - The class name of the object to spawn as a marker

Returns:
    NOTHING

Examples:
    (begin example)
        [
            _vehicle,
            "Sign_Arrow_Large_Cyan_F"
        ] call KISKA_TEST_fnc_convoy_setVehicleDebugMarkerType_followPath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_setVehicleDebugMarkerType_followPath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_type","Sign_Arrow_Large_Cyan_F",[""]]
];


_vehicle setVariable ["KISKA_convoy_debugMarkerType_followPath",_type];
