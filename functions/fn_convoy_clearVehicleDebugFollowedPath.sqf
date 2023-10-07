/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_clearVehicleDebugFollowedPath

Description:
	Clears a vehicle's current debug followed path objects array. 

    When a vehicle is in debug mode, a path of objects will be drawn for the duration
     that shows the positions the vehicle had followed while on its drive path. One 
     followed object is created each time a drive path point is considered "complete"
     (vehicle within a radius of that point).
    
Parameters:
    0: _vehicle <OBJECT> - The vehicle to clear the debug followed path of
    1: _deleteExisting <BOOL> - Whether or not to delete the objects that are
        currently in the array

Returns:
    NOTHING

Examples:
    (begin example)
		[_vehicle] call KISKA_TEST_fnc_convoy_clearVehicleDebugFollowedPath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_clearVehicleDebugFollowedPath";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
    ["_deleteExisting",true,[true]]
];

if (isNull _vehicle) exitWith {
    ["_vehicle is null"] call KISKA_fnc_log;
    nil
};


if (_deleteExisting) then {
    ([_vehicle] call KISKA_TEST_fnc_convoy_getVehicleDebugFollowedPath) apply {
        deleteVehicle _x;
    };
};
_vehicle setVariable ["KISKA_convoy_debug_followedPathObjects",[]];
