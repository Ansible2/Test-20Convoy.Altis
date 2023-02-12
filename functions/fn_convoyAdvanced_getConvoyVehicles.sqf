/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getConvoyVehicles

Description:
    Returns the list of vehicles in a convoy.

Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap get vehicles from

Returns:
    <OBJECT[]> - an array containing each vehicle (in there convoy order)

Examples:
    (begin example)
		private _convoyVehicles = [
			SomeConvoyHashMap
		] call KISKA_fnc_convoyAdvanced_getConvoyVehicles;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getConvoyVehicles";

params ["_convoyHashMap"];


_convoyHashMap getOrDefault ["_convoyVehicles",[]]
