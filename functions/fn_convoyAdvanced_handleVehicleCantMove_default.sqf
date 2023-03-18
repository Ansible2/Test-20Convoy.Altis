
// TODO: finish function to find out what (if any) side is clear
private _findClearSide = {
    params ["_disabledVehicle","_affectedPositionsATL","_requiredSpace"];

    (_affectedPositionsATL select 0) params ["_closestAffectedPosition"];
    
    private _affectedPositionsCount = count _affectedPositionsATL;
    private _middleIndex = (round (_affectedPositionsCount / 2)) - 1;
    (_affectedPositionsATL select _middleIndex) params ["_middleAffectedPosition"];
    
    private _lastIndex = _affectedPositionsCount - 1;
    (_affectedPositionsATL select _lastIndex) params ["_lastAffectedPosition"];
    

    private _disabledVehicle_dir = getDirVisual _disabledVehicle;
    private _leftAzimuth = 270 + _disabledVehicle_dir;
    private _rightAzimuth = 90 + _disabledVehicle_dir;

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
            private _positionLeftASL = AGLToASL(_positionASL getPos [_requiredSpace, _leftAzimuth]);
            private _objectsOnLeft = lineIntersectsObjs [_positionASL, _positionLeftASL, _disabledVehicle, objNull,true,32];
            private _objectsAreOnTheLeft = _objectsOnLeft isNotEqualTo [];

            // DEBUG
            createVehicle ["Sign_Arrow_Large_Green_F",(ASLToATL _positionLeftASL),[],0,"CAN_COLLIDE"];
            
            if (_objectsAreOnTheLeft) then { _clearLeft = false; };
        };

        if (_clearRight) then {
            private _positionRightASL = AGLToASL(_positionASL getPos [_requiredSpace, _rightAzimuth]);
            private _objectsOnRight = lineIntersectsObjs [_positionASL, _positionRightASL, _disabledVehicle, objNull,true,32];
            private _objectsAreOnTheRight = _objectsOnRight isNotEqualTo [];
            
            // DEBUG
            createVehicle ["Sign_Arrow_Large_Green_F",(ASLToATL _positionRightASL),[],0,"CAN_COLLIDE"];
            
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

private _fn_getAffectedPositions = {
    params ["_vehicleBehind_path","_disabledVehicle","_disabledVehicle_boundingBox"];

    private _disabledVehicle_boundingBox = 0 boundingBoxReal _disabledVehicle;
    private _boxMins = _disabledVehicle_boundingBox select 0; 
    private _boxMaxes = _disabledVehicle_boundingBox select 1; 
    // x and y are not halved because while it would be more precise, we
    // need to make sure there is enough clearance for vehicles to actually
    // pass by the side of it
    private _disabledVehicle_halfWidth = (abs ((_boxMaxes select 0) - (_boxMins select 0))) / 2;
    private _areaX = _disabledVehicle_halfWidth + 5;
    private _areaY = (abs ((_boxMaxes select 1) - (_boxMins select 1))) / 2 + 10;
    private _areaZ = (abs ((_boxMaxes select 2) - (_boxMins select 2))) / 2;
    private _areaCenter = ASLToAGL (getPosASLVisual _disabledVehicle);
    private _lastIndex = (count _vehicleBehind_path) - 1;
    
    private _affectedPositionsATL = [];
    {
        if (_forEachIndex isEqualTo _lastIndex) then { break };

        private _areaAngle = _x getDir (_vehicleBehind_path select (_forEachIndex + 1));
        private _pointIsInArea = _x inArea [
            _areaCenter,
            _areaX,
            _areaY,
            _areaAngle,
            true,
            _areaZ
        ];

        private _anAffectedPositionWasFound = _affectedPositionsATL isNotEqualTo [];
        if (_anAffectedPositionWasFound AND (!_pointIsInArea)) then { break };

        if (_pointIsInArea) then {
            _affectedPositionsATL pushBack [_x,_forEachIndex];
        };

    } forEach _vehicleBehind_path;


    _affectedPositionsATL
};

private _disabledVehicle = vic;
private _vehicleBehind = vic1;
private _vehicleBehind_path = (["pathLayer"] call KISKA_fnc_getMissionLayerObjects) apply { getPosATLVisual _x };
private _disabledVehicle_boundingBox = 0 boundingBoxReal _disabledVehicle;

private _affectedPositionsATL = [
    _vehicleBehind_path,
    _disabledVehicle,
    _disabledVehicle_boundingBox
] call _fn_getAffectedPositions;

if (_affectedPositionsATL isNotEqualTo []) then {
    private _vehicleBehind_boundingBox = 0 boundingBoxReal _vehicleBehind;
    private _vehicleBehind_boxMins = _vehicleBehind_boundingBox select 0; 
    private _vehicleBehind_boxMaxes = _vehicleBehind_boundingBox select 1; 
    private _vehicleBehind_width = abs ((_vehicleBehind_boxMaxes select 0) - (_vehicleBehind_boxMins select 0));

    private _boxMins = _disabledVehicle_boundingBox select 0; 
    private _boxMaxes = _disabledVehicle_boundingBox select 1; 
    private _disabledVehicle_halfWidth = (abs ((_boxMaxes select 0) - (_boxMins select 0))) / 2;

    private _clearSide = [
        _disabledVehicle,
        _affectedPositionsATL,
        (_vehicleBehind_width + 2 + _disabledVehicle_halfWidth)
    ] call _findClearSide;
    

    private _noSideIsClear = _clearSide isEqualTo -1;
    if (_noSideIsClear) exitWith {};

    private _adjustmentDistance = _vehicleBehind_width + _disabledVehicle_halfWidth + 2;
    private _disabledVehicle_dir = getDirVisual _disabledVehicle;
    // [left,right] select _clearSide
    private _adjustmentDirectionBase = [270,90] select _clearSide;
    private _adjustmentAzimuth = _adjustmentDirectionBase + _disabledVehicle_dir;
    
    private _firstPosition = (_affectedPositionsATL select 0) select 0;
    private _firstPositionAdjusted = ASLToATL(AGLToASL(_firstPosition getPos [_adjustmentDistance, _adjustmentAzimuth]));
    private _vectorOffset = _firstPosition vectorDiff _firstPositionAdjusted;

    // DEBUG
    private _colorTypes = ["Sign_Arrow_Large_Yellow_F", "Sign_Arrow_Large_F", "Sign_Arrow_Large_Pink_F"];
    private _rotation = 0;

    _affectedPositionsATL apply {
        _x params ["_position","_index"];
        private _positionAdjusted = _position vectorDiff _vectorOffset;
        _vehicleBehind_path set [_index,_positionAdjusted];

        // DBEUG
        createVehicle [_colorTypes select _rotation,_positionAdjusted,[],0,"CAN_COLLIDE"];
        _rotation = _rotation + 1;
        if (_rotation > 2) then {_rotation = 0};
    };

};





_vehicleBehind_path apply {
    _x pushBack 20;
};
vic1 setDriveOnPath _vehicleBehind_path;                                    