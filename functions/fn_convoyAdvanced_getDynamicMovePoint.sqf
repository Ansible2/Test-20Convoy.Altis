/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getDynamicMovePoint

Description:
    Gets the dynamic move point for a given vehicle in a convoy.

	See KISKA_fnc_convoyAdvanced_setDynamicMovePoint more details on dynamic move points.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to get the dynamic move point of

Returns:
    <PositionATL> - The position if it is currently defined (nil if not)

Examples:
    (begin example)
        private _position = [
			vic
		] call KISKA_fnc_convoyAdvanced_getDynamicMovePoint;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getDynamicMovePoint";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]]
];

if (isNull _vehicle) exitWith {
	["_vehicle is null",true] call KISKA_fnc_log;
	nil
};


_vehicle getVariable "KISKA_convoyAdvanced_dynamicMovePoint"
