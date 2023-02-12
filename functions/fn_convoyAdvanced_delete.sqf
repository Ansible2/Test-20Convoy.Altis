/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_delete

Description:
    Deletes an instance of a KISKA convoy. All vehicles (that aren't the lead)
	 will halt. This can be executed at any time on a convoy.

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to add to

Returns:
    <> - 

Examples:
    (begin example)
        
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_delete";

params [
    ["_convoyHashMap",nil,[createHashMap]]
];


if (isNil "_convoyHashMap") exitWith {
    ["_convoyHashMap is nil",true] call KISKA_fnc_log;
    nil
};


private _convoyVehicles = [
	_convoyHashMap
] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;
_convoyVehicles apply {
	[_x] call KISKA_fnc_convoyAdvanced_removeVehicle;
};

private _convoyStatemachine = [
    _convoyHashMap
] call KISKA_fnc_convoyAdvanced_getConvoyStatemachine;
[_convoyStatemachine] call CBA_statemachin_fnc_delete;


nil
