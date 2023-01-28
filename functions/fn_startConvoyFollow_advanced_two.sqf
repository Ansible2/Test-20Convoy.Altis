scriptName "KISKA_fnc_startConvoyFollowAdvanced";

params ["_vics"];

private _leadVic = _vics select 0;
_vics apply {
    if (_x isEqualTo _leadVic) then {continue};

    doStop (driver _x);
    _x engineOn true;
};

sleep 1;

KISKA_doTheThing = true;
// todo: should add speed to the points probably
// vehicles should only be able to move to a point once the vehicle ahead is not within the radius of it such that they will not crash into the vehicle ahead
[
    {
        params ["_args","_handle"];
        _args params ["_vics","_leadVic"];
        {
            private _currentVehicle = _x;
            if (_currentVehicle isEqualTo _leadVic) then {continue};
            
            /* ----------------------------------------------------------------------------
                setup for rest of function
            ---------------------------------------------------------------------------- */
            private _vehicleAhead = _vics param [_forEachIndex - 1, objNull];
            private _vehicleAheadPosition = getPosATL _vehicleAhead;
            private _currentVehicleDrivePath = _currentVehicle getVariable ["KISKA_convoyDrivePath",[]];
            private _currentVehicleDrivePath_debug = _currentVehicle getVariable ["KISKA_convoyDrivePath_debug",[]];
            if (_currentVehicleDrivePath isEqualTo []) then {
                _currentVehicleDrivePath pushBack _vehicleAheadPosition;
                private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _vehicleAheadPosition, [], 0, "CAN_COLLIDE"];
                _currentVehicleDrivePath_debug pushBack _debugObject;

                _currentVehicle setVariable ["KISKA_convoyDrivePath",_currentVehicleDrivePath];
                _currentVehicle setVariable ["KISKA_convoyDrivePath_debug",_currentVehicleDrivePath_debug];
            };


            /* ----------------------------------------------------------------------------
                Delete old points
            ---------------------------------------------------------------------------- */
            private _currentVehiclePosition = getPosATLVisual _currentVehicle;
            private _deleteStartIndex = -1;
            private _numberToDelete = 0;
            {
                private _withinOneMeter = (_currentVehiclePosition distance _x) <= 8;

                if !(_withinOneMeter) then {break};
                _numberToDelete = _numberToDelete + 1;
                // hint str [(_currentVehiclePosition distance _x), _numberToDelete];

                if (_deleteStartIndex isNotEqualTo -1) then {continue};
                _deleteStartIndex = _forEachIndex;

            } forEach _currentVehicleDrivePath;

            // first point is not marked with marker
            if (_deleteStartIndex >= 0) then {
                // [["_deleteStartIndex: ",_deleteStartIndex," _numberToDelete: ",_numberToDelete]] call KISKA_fnc_log;
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
            // the follow vehicle can simply queue the vehicleAheadPosition and then the next loop iteration, just needs
            // to check if the vehicle is out of the way, in which case it can add it to the list

            private _queuedPoint = _currentVehicle getVariable ["KISKA_queuedConvoyPoint",[]];
            private _bufferDistanceToNextVehicle = (sizeOf (typeOf _vehicleAhead)) + 2;
            if (_queuedPoint isNotEqualTo []) then {
                private _distanceToQueuedPoint = _vehicleAheadPosition distance _queuedPoint;

                private _vehicleAheadHasMovedFromQueuedPoint = _distanceToQueuedPoint > _bufferDistanceToNextVehicle;
                if (!_vehicleAheadHasMovedFromQueuedPoint) then {
                    // [str [_currentVehicleDrivePath,"_queuedPoint not far enough"] ] call KISKA_fnc_log;
                    str [_currentVehicleDrivePath,"_queuedPoint not far enough"]; 
                    continue 
                };

                private _indexInserted = _currentVehicleDrivePath pushBack _queuedPoint;
                _currentVehicle setVariable ["KISKA_queuedConvoyPoint",nil];

                private _debugObject = createVehicle ["Sign_Arrow_Large_Cyan_F", _queuedPoint, [], 0, "CAN_COLLIDE"];
                _currentVehicleDrivePath_debug pushBack _debugObject;
                // [str [_currentVehicleDrivePath,"added to drive path"] ] call KISKA_fnc_log;
                hint str [_currentVehicleDrivePath,"added to drive path"];

                if (_indexInserted >= 1) then {
                    _currentVehicle setDriveOnPath _currentVehicleDrivePath;
                    // [str [_currentVehicleDrivePath,"executed drive path"] ] call KISKA_fnc_log;
                    hint str [_currentVehicleDrivePath,"executed drive path"];
                };

                continue;
            };

            
            private _distanceToLastDrivePoint = _vehicleAheadPosition distance _lastestPointToDriveTo;
            // noone else behind in the convoy should move if the vehicle ahead has not moved a significant amount
            private _currentVehiclePathCount = count _currentVehicleDrivePath;
            private _lastIndexInCurrentPath = (_currentVehiclePathCount - 1) max 0;
            private _lastestPointToDriveTo = _currentVehicleDrivePath param [_lastIndexInCurrentPath,[]];
            private _distanceToLastDrivePoint = _vehicleAheadPosition distance _lastestPointToDriveTo;
            private _vehicleAheadHasMovedFarEnoughFromLastPoint = _distanceToLastDrivePoint > _bufferDistanceToNextVehicle;
            if !(_vehicleAheadHasMovedFarEnoughFromLastPoint) then { continue };
            
            _currentVehicle setVariable ["KISKA_queuedConvoyPoint",_vehicleAheadPosition];
            // [str  [_currentVehicleDrivePath,"set KISKA_queuedConvoyPoint"] ] call KISKA_fnc_log; 
            hint str [_currentVehicleDrivePath,"set KISKA_queuedConvoyPoint"];
        } forEach _vics;
    },
    0.05,
    [_vics,_leadVic]
] call CBA_fnc_addPerFrameHandler