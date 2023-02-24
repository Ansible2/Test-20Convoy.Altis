/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_setDynamicMovePoint

Description:
    Sets the dynamic move point for a given vehicle in a convoy.

	A dynamic move point for a vehicle in a convoy is an ATL position that a given 
	 convoy vehicle should be moving towards. The assumption is that a convoy FOLLOW 
	 vehicle was told to move to certain position outside of the convoy movement.
	
	This specific vehicle will not be given any movement orders from the convoy system
	 until it is near the dynamic move point. Once the vehicle is close enough, 
	 the dynamic move point will be removed and the vehicle will attempt to resume following
	 the lead vehicle.
	
	See KISKA_fnc_convoyAdvanced_setDynamicMovePointCompletionRadius for controlling the
	 distance the vehicle needs to be from this point in order for it to complete.

Parameters:
    0: _vehicle <OBJECT> - The vehicle to set the dynamic move point of
    1: _position <PositionATL> - The position for that the vehicle will move to

Returns:
    NOTHING

Examples:
    (begin example)
        [vic,[0,0,0]] call KISKA_fnc_convoyAdvanced_setDynamicMovePoint;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_setDynamicMovePoint";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_vehicle",objNull,[objNull]],
	["_position",[],[[]]]
];

if (isNull _vehicle) exitWith {
	["_vehicle is null",true] call KISKA_fnc_log;
	nil
};

if (_position isEqualTo []) exitWith {
	["_position is undefined",true] call KISKA_fnc_log;
    nil
};


_vehicle setVariable ["KISKA_convoyAdvanced_dynamicMovePoint",_position];
