---
title: behaviour of vehuicle locking system
layout: default
description: concrete example drawn from 2019 Ford Transit users handbook
---
```alloy
module VehicleLocking

open Vehicle //includes Door
open Location
open Lock
open Transit

//global facts
fact doorsAreOnOneVehicleOnly{
    doors in Vehicle one -> Door
}

fact noUnneededLocations{
    all l: Location |
        some v: Vehicle |
            l in v.locations
}

//Checks
//The below should be true of the above:
pred aVehicleHasLocationsForDoors{
    all v: Vehicle |  v.locations != none
}

pred aDoorBelongsToAVehicle{
    all d: Door |
        one v: Vehicle |
            d in v.doors
}

pred aDoorIsInALocationOnAVehicle{
    all d: Door |
        one v: Vehicle |
            one l: v.locations |
                d = v.doorAt[l]
}

pred aDoorIsOnOneVehicleOnly{
    all disj u, v: Vehicle |
        no v.doors & u.doors
} 

pred aDoorIsInOneLocationOnly{
    all v: Vehicle |
        all d: v.doors |
            one v.doorAt :> d
}

pred doorsChangeStateTogether{
    all v: Vehicle | 
        no v.doors.lockState :> Locked or
        no v.doors.lockState :> Unlocked
}    

//it's a shame that we can't organize assertions this way, too. [or can we!?]
pred validStructure{
    aVehicleHasLocationsForDoors
    aDoorBelongsToAVehicle
    aDoorIsInOneLocationOnly
}

pred consistentBehaviour{
    doorsChangeStateTogether
}

pred vehicleModel{
    validStructure
    consistentBehaviour
}

check theModelAsChecked{vehicleModel} for exactly 2 Transit, 8 Door, 4 Location expect 0 //counterexamples

//traces

pred doorsAreLocked{
    all v: Vehicle |
        all d: v.doors |
            d.locked
}

pred begin{
    doorsAreLocked
}

pred someValidChanges{
    always {
         some v: Vehicle |
             (v.lockCommanded   and all vv: Vehicle - v | vv.unchanged) or
             (v.unlockCommanded and all vv: Vehicle - v | vv.unchanged) or
             v.unchanged
    }
}

pred targetState{
    eventually {
        all d: Door | d.unlocked
    }
}

pred trace{
    begin
    someValidChanges
    targetState
}

//As  we should see demonstrated thus:
run singleVanBehaviour{trace} for exactly 1 Transit, 8 Door, 4 Location, 4 Time
run multipleVanBehaviour{trace} for exactly 2 Transit, 8 Door, 4 Location, 4 Time
```
