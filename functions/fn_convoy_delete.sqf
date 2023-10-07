/* ----------------------------------------------------------------------------
Function: KISKA_TEST_fnc_convoy_delete

Description:
    Deletes an instance of a KISKA convoy. All vehicles (that aren't the lead)
	 will halt. This can be executed at any time on a convoy.

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to add to

Returns:
    NOTHING

Examples:
    (begin example)
        private _convoyHashMap = [
            [leadVehicle],
            10
        ] call KISKA_TEST_fnc_convoy_create;
        // some time later...
        [_convoyHashMap] call KISKA_TEST_fnc_convoy_delete;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_TEST_fnc_convoy_delete";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    nil
};

params [
    ["_convoyHashMap",nil]
];


if (isNil "_convoyHashMap") exitWith {
    ["_convoyHashMap is nil",true] call KISKA_fnc_log;
    nil
};


private _convoyVehicles = [
	_convoyHashMap
] call KISKA_TEST_fnc_convoy_getConvoyVehicles;
_convoyVehicles apply {
	[_x] call KISKA_TEST_fnc_convoy_removeVehicle;
};

private _convoyStatemachine = [
    _convoyHashMap
] call KISKA_TEST_fnc_convoy_getConvoyStatemachine;
[_convoyStatemachine] call CBA_statemachine_fnc_delete;


(keys _convoyHashMap) apply { _convoyHashMap deleteAt _x };

nil
