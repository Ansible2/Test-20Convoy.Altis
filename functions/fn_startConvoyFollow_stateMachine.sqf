params ["_vics"];

if (_vics isEqualTo []) exitWith {
    ["_vics is empty array",true] call KISKA_fnc_log;
    nil
};

private _stateMachine = [
    _vics,
    true
] call CBA_stateMachine_fnc_create;

private _convyHashMap = createHashMap;
_convyHashMap set ["_stateMachine",_stateMachine];
_convyHashMap set ["_convoyLead",_vics select 0];
_convoyHashMap set ["_convoyVehicles",_vics];

{
    _x setVariable ["KISKA_convoy_hashMap",_convyHashMap];
    if (_forEachIndex isEqualTo 0) then { continue };

    _x setVariable ["KISKA_convoy_vehicleAhead",_vics select (_forEachIndex - 1)];
} forEach _vics;




private _onEachFrame = {
    private _vehicle = _this;
    private _convoyHashMap = _vehicle getVariable "KISKA_convoy_hashMap";
    private _convoyLead = _convoyHashMap get "_convoyLead";
    // private _stateMachine = _convoyHashMap get "_stateMachine";

    if (_vehicle isEqualTo _convoyLead) exitWith {};

    /* ----------------------------------------------------------------------------
        
    ---------------------------------------------------------------------------- */
    private _vehicleAhead = _vehicle getVariable ["KISKA_convoy_vehicleAhead",objNull];
    private _vehicleAheadPosition = getPosATLVisual _vehicleAhead;
    private _currentVehicleDrivePath = _currentVehicle getVariable "KISKA_convoyDrivePath";
    private _currentVehicleDrivePath_debug = _currentVehicle getVariable "KISKA_convoyDrivePath_debug";

    if (isNil "_currentVehicleDrivePath") then {
        _currentVehicleDrivePath = [];
        _currentVehicleDrivePath_debug = [];
        _currentVehicle setVariable ["KISKA_convoyDrivePath",_currentVehicleDrivePath];
        _currentVehicle setVariable ["KISKA_convoyDrivePath_debug",_currentVehicleDrivePath_debug];
    };


    /* ----------------------------------------------------------------------------
        Delete old points
    ---------------------------------------------------------------------------- */
    private _currentVehiclePosition = getPosATLVisual _currentVehicle;
    private _deleteStartIndex = -1;
    private _numberToDelete = 0;
    private _distanceToPoint = 10;
    {
        private _withinOneMeter = (_currentVehiclePosition distance _x) <= _distanceToPoint;

        if !(_withinOneMeter) then { break };
        _numberToDelete = _numberToDelete + 1;

        if (_deleteStartIndex isNotEqualTo -1) then { continue };
        _deleteStartIndex = _forEachIndex;

    } forEach _currentVehicleDrivePath;

    // first point is not marked with marker
    if (_deleteStartIndex >= 0) then {
        _currentVehicleDrivePath deleteRange [_deleteStartIndex,_numberToDelete];
        private _lastIndexToDelete = _deleteStartIndex + (_numberToDelete - 1);
        createVehicle ["Sign_Arrow_Large_blue_F", _currentVehiclePosition, [], 0, "CAN_COLLIDE"];

        for "_i" from _deleteStartIndex to _lastIndexToDelete do { 
            deleteVehicle (_currentVehicleDrivePath_debug select _i);
        };
        _currentVehicleDrivePath_debug deleteRange [_deleteStartIndex,_numberToDelete];
    };


    /* ----------------------------------------------------------------------------
        create new points
    ---------------------------------------------------------------------------- */
    private _queuedPoint = _currentVehicle getVariable ["KISKA_convoy_queuedPoint",[]];
};



private _mainState = [
    _stateMachine,
    _onEachFrame
] call CBA_stateMachine_fnc_addState;

