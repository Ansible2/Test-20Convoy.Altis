/* ----------------------------------------------------------------------------
Function: KISKA_fnc_convoyAdvanced_getConvoyLeader

Description:
    Gets the lead vehicle in a convoy. The convoy lead does not have his movement
     regulated in any way by the advanced convoy system and will be the vehicle that
     other units in the convoy follow.
         
Parameters:
    0: _convoyHashMap <HASHMAP> - The convoy hashmap to get the value from

Returns:
    <OBJECT> - The lead vehicle in the convoy

Examples:
    (begin example)
        private _convoyLeader = [
			_convoyHashMap
		] call KISKA_fnc_convoyAdvanced_getConvoyLeader;
    (end)

Author(s):
    Ansible2
---------------------------------------------------------------------------- */
scriptName "KISKA_fnc_convoyAdvanced_getConvoyLeader";

params ["_convoyHashMap"];


_convoyHashMap getOrDefault ["_convoyLead",objNull]
