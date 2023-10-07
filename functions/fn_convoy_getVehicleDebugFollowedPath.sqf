/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_getVehicleDebugFollowedPath

Description:
    Gets a vehicle's current debug followed path objects array. 
    
    When a vehicle is in debug mode, a path of objects will be drawn for the duration
     that shows the positions the vehicle had followed while on its drive path. One 
     followed object is created each time a drive path point is considered "complete"
     (vehicle within a radius of that point).

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the follow path of

Returns:
    <OBJECT[]> - An array of the vehicle's followed path objects

Examples:
    (begin example)
        private _debugFollowedPathObjects = [
            _vehicle
        ] call KISKA_TEST_fnc_convoy_getVehicleDebugFollowedPath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_getVehicleDebugFollowedPath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    []
};

params [
    ["_vehicle",objNull,[objNull]]
];


_vehicle getVariable ["KISKA_convoy_debug_followedPathObjects",[]]
