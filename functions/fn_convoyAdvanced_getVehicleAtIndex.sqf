/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getVehicleAtIndex

Description:
    Gets the a vehicle at the specified index of a convoy. 
    
    For example, the convoy leader is the vehicle at index 0 
     and the vehicle directly behind the leader is index 1.
         
Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to get the value from
    1: _index <NUMBER> - The convoy hashmap to get the value from

Returns:
    <OBJECT> - The vehicle at the desired index

Examples:
    (begin example)
        private _convoyLeader = [
			_convoyHashMap,
            0
		] call KISKA_fnc_convoyAdvanced_getVehicleAtIndex;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getVehicleAtIndex";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    objNull
};

params [
    "_convoyHashMap",
    ["_index",1,[123]]
];


_convoyHashMap getOrDefault [_index,objNull]
