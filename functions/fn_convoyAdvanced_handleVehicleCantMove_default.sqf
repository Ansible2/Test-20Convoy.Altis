
// TODO: finish function to find out what (if any) side is clear
private _findClearSide = {
    params ["_disabledVehicle","_affectedPositions","_requiredSpace"];

    private _closestAffectedPosition = _affectedPositions select 0;
    private _affectedPositionsCount = count _affectedPositions;
    private _middleIndex = (round (_affectedPositionsCount / 2)) - 1;
    private _middleAffectedPosition = _affectedPositions select _middleIndex;
    private _lastAffectedPosition = _affectedPositions select (_affectedPositionsCount - 1);

    private _clearSide = -1;
    private _clearLeft = true;
    private _clearRight = true;
    [
        _closestAffectedPosition,
        _middleAffectedPosition,
        _lastAffectedPosition
    ] apply {
        private _positionASL = ATLToASL _x;
        // TODO: handle the case where _disabledVehicle is in a large open area
        /// but there are a series of obstacles to its side WITHIN 20m, but the 30m past that are clear

        // checking a minimum of 5m from the _disabledVehicle in order to have a decent buffer
        // also stepping by 5 just in case you have a wide open area to go around
        /// but say you have some objects just close to the _disabledVehicle but plenty of space beyond that

        if (_clearLeft) then {
            private _positionLeft = AGLToASL (_x getRelPos [_requiredSpace, 270]);
            private _objectsOnLeft = lineIntersectsObjs [_positionASL, _positionLeft, _disabledVehicle, objNull,true,32];
            private _objectsAreOnTheLeft = _objectsOnLeft isNotEqualTo [];
            if (_objectsAreOnTheLeft) then { _clearLeft = false; };
        };

        if (_clearRight) then {
            private _positionRight = AGLToASL (_x getRelPos [_requiredSpace, 90]);
            private _objectsOnRight = lineIntersectsObjs [_positionASL, _positionRight, _disabledVehicle, objNull,true,32];
            private _objectsAreOnTheRight = _objectsOnRight isNotEqualTo [];
            if (_objectsAreOnTheRight) then { _clearRight = false };
        };

        if !(_clearLeft AND _clearRight) then { break };
    };

    if (_clearLeft) then {
        _clearSide = 0;
    } else {
        if (_clearRight) then { _clearSide = 1; };
    };


    _clearSide
};




private _disabledVehicle = vic;
private _vehicleBehind = vic1;

private _disabledVehicleBoundingBox = 0 boundingBoxReal vic;
private _boxMins = _disabledVehicleBoundingBox select 0; 
private _boxMaxes = _disabledVehicleBoundingBox select 1; 
// x and y are not halved because while it would be more precise, we
// need to make sure there is enough clearance for vehicles to actually
// pass by the side of it
private _disabledVehicle_halfWidth = (abs ((_boxMaxes select 0) - (_boxMins select 0))) / 2
private _areaX = _disabledVehicle_halfWidth + 5;
private _areaY = (abs ((_boxMaxes select 1) - (_boxMins select 1))) / 2 + 10;
private _areaZ = (abs ((_boxMaxes select 2) - (_boxMins select 2))) / 2;
private _areaCenter = ASLToAGL (getPosASLVisual _disabledVehicle);

private _vehicleBehind_path = (["pathLayer"] call KISKA_fnc_getMissionLayerObjects) apply { getPosASLVisual _x };
private _startIndex = -1;
private _endIndex = -1;
{
    private _areaAngle = _x getDir (_vehicleBehind_path param [_forEachIndex + 1,[0,0,0]]);
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
    private _vehicleBehind_boundingBox = 0 boundingBoxReal _vehicleBehind;
    private _vehicleBehind_boxMins = _vehicleBehind_boundingBox select 0; 
    private _vehicleBehind_boxMaxes = _vehicleBehind_boundingBox select 1; 
    private _vehicleBehind_width = abs ((_vehicleBehind_boxMaxes select 0) - (_vehicleBehind_boxMins select 0));

    // 1. find clearest side
    private _clearSide = [
        _disabledVehicle,
        _affectedPositions,
        (_vehicleBehind_width + 2 + _disabledVehicle_halfWidth)
    ] call _findClearSide;

    private _noSideIsClear = _clearSide isEqualTo -1;
    if (_noSideIsClear) exitWith {};

    _affectedPositions apply {
        // TODO: determine how to edit affected position in _vehicleBehind_path

        // using the provided widths, adjust positions in path to be spaced around
        // 2. take lineIntersect out to ~25m (maybe less) to find a path by
            // a. walk in the lineIntersect 1-2m increments until it can be fit
            // b. do not allow the point in the earlier bounding box of affected points
        // 3. place the affected point at the farthest possible point along the line
        /// in which there is no intersection

        // NOTE: also need to account for the bounding box of the vehicle that is trying to get through
    };
};