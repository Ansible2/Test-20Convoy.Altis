private _disabledVehicle = vic;

private _disabledVehicleBoundingBox = 0 boundingBoxReal vic;
private _boxMins = _disabledVehicleBoundingBox select 0; 
private _boxMaxes = _disabledVehicleBoundingBox select 1; 
// x and y are not halved because while it would be more precise
// need to make sure there is enough clearance for vehicles to actually
// pass by the side of it
private _areaX = (abs ((_boxMaxes select 0) - (_boxMins select 0)));
private _areaY = (abs ((_boxMaxes select 1) - (_boxMins select 1)));
private _areaZ = (abs ((_boxMaxes select 2) - (_boxMins select 2))) / 2;
private _areaCenter = ASLToAGL (getPosASLVisual _disabledVehicle);

private _vehicleBehind_path = (["pathLayer"] call KISKA_fnc_getMissionLayerObjects) apply {getPosASLVisual _x};
private _startIndex = -1;
private _endIndex = -1;
{
    private _areaAngle = _x getDir (_vehicleBehind_path param [_forEachIndex + 1,[0,0,0]])
    private _pointIsInArea = _x inArea [
        _areaCenter,
        _areaX,
        _areaY,
        _areaAngle,
        true,
        _areaZ
    ];

    if (_pointIsInArea) then {
        if (_startIndex isEqualTo -1) then {
            _startIndex = _forEachIndex;
            _endIndex = _forEachIndex;
        } else {
            _endIndex = _forEachIndex;
        };

        continue;

    } else {
        if (_startIndex isNotEqualTo -1) then { break };

    };

} forEach _vehicleBehind_path;

if (_startIndex isNotEqualTo -1) then {
    private _affectedPositions = _vehicleBehind_path select [_startIndex,_endIndex + 1];

    _affectedPositions apply {
        // TODO: determine how to edit affected position in _vehicleBehind_path
    };
};