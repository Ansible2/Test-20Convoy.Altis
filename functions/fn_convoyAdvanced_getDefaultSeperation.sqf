/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_setDefaultSeperation

Description:
    Gets the default seperation between NEWLY added vehicles to a convoy.
    
	This is the seperation that vehicles will get by default when they are
	 added to the convoy.
    
Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to get the value from

Returns:
    <NUMBER> - The default sepration between newly added convoy vehicles

Examples:
    (begin example)
        private _defaultSeperation = [
			_convoyHashMap
		] call KISKA_fnc_convoyAdvanced_getDefaultSeperation;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getDefaultSeperation";

if (!isServer) exitWith {
    ["Must be executed on the server!",true] call KISKA_fnc_log;
    -1
};

params [
    "_convoyHashMap"
];

_convoyHashMap getOrDefault ["_convoySeperation",20]
