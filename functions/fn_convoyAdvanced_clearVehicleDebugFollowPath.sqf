/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_clearVehicleDebugFollowPath

Description:
	Clears a vehicle's current debug follow path objects array. 

    When a vehicle is in debug mode, a path of objects will be drawn for the duration
     that shows the positions currently in the vehicle's drive path. This is the follow
     path. 
    
Parameters:
    0: _vehicle <OBJECT> - The vehicle to clear the debug follow path of
    1: _deleteExisting <BOOL> - Whether or not to delete the objects that are
        currently in the array

Returns:
    NOTHING

Examples:
    (begin example)
		[_vehicle] call KISKA_fnc_convoyAdvanced_clearVehicleDebugFollowPath;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_clearVehicleDebugFollowPath";

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
    (_vehicle getVariable ["KISKA_convoyAdvanced_debug_followPathObjects",[]]) apply {
        deleteVehicle _x;
    };
};
_vehicle setVariable ["KISKA_convoyAdvanced_debug_followPathObjects",[]];
