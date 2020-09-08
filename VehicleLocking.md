---
---
# Behaviour of a vehicle locking system

Concrete example drawn from 2019 Ford Transit users handbook.

```alloy
module VehicleLocking

open Vehicle //includes RemoteFob, opens Door, 
open Location
open Lock
open Transit

```
##cross-module facts
```alloy
fact doorsAreOnOneVehicleOnly{
    doors in Vehicle one -> Door
}

fact noUnneededLocations{
    all l: Location |
        some v: Vehicle |
            l in v.locations
}

```

## Checks
The below claims should be true of the above model:

### Structure
```alloy
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
                d = v.doorAtLocation[l]
}

pred aDoorIsOnOneVehicleOnly{
    all disj u, v: Vehicle |
        no v.doors & u.doors
} 

pred aDoorIsInOneLocationOnly{
    all v: Vehicle |
        all d: v.doors |
            one v.doorAtLocation :> d
}

pred aDoorIsInAZone{
   all d: Door |
      one z: Zone |
          one v: Vehicle |
             d in v.doorsInZone[z]
}
   
pred aPeopleZoneContainsTheDoorsForPeople{
   all v: Vehicle |
      all l: v.locations |
          l.purpose in ForPeople => some z: v.zones | z in People and l in v.locationsByZone[z]
}

pred aCargoZoneContainsTheDoorsForCargo{
   all v: Vehicle |
      all l: v.locations |
          l.purpose in ForCargo => some z: v.zones | z in Cargo and l in v.locationsByZone[z]
}
```
collecting all that together for convenience:

```alloy
pred validStructure{
    aVehicleHasLocationsForDoors
    aDoorBelongsToAVehicle
    aDoorIsInOneLocationOnly
    aDoorIsInAZone 
    aPeopleZoneContainsTheDoorsForPeople
    aCargoZoneContainsTheDoorsForCargo
}
```
### Behaviour

Idiom: quantify a union expression with `no` to assert that the sets are disjoint

```alloy

pred doorsInAZoneHaveTheSameLockState{
    all v: Vehicle |
        all z: v.zones | 
           no v.doorsInZone[z] & v.lockedDoors or
           no v.doorsInZone[z] & v.unlockedDoors
}

pred doorsChangeStateOnlyOnFobCommands{
    all f: RemoteFob |
        let v = f.vehicle |
            v.lockStatusUnchanged until f.unlockCommanded or f.lockCommanded        
}


```
collecting all that together for convenience:

```alloy
pred consistentBehaviour{
    doorsInAZoneHaveTheSameLockState
    doorsChangeStateOnlyOnFobCommands
}

```
Checking structure and behaviour together for convenience:

```alloy
pred vehicleLockingModel{
    validStructure
    consistentBehaviour
}

check theModelAsChecked{vehicleLockingModel} for exactly 2 Transit, 2 RemoteFob, 8 Door, 4 Location, 4 Time expect 0 //counterexamples
```
## Demonstration

```alloy

pred begin{
    all v: Vehicle |
        v.allLocked 
}

pred someValidChanges{
    always {
         some f: RemoteFob |
            let v = f.vehicle |
                 v.unlockEffects = People + Cargo => (
                     (f.lockCommanded   and v.allDoorsLocked   and allVehiclesUnchagedExcept[v]) or
                     (f.unlockCommanded and v.allDoorsUnlocked and allVehiclesUnchagedExcept[v]) or
                     f.vehicle.unchanged)
                 or 
                 v.unlockEffects = People => (
                     (f.lockCommanded   and v.allDoorsLocked          and allVehiclesUnchagedExcept[v]) or
                     (f.unlockCommanded and v.peopleDoorsUnlockedOnly and allVehiclesUnchagedExcept[v]) or
                     f.vehicle.unchanged)
    }
}

pred targetState{
    eventually {   
        all v: Vehicle |
            v.allUnlocked
        }
}

pred trace{
    begin
    someValidChanges
    targetState
}

//As  we should see demonstrated thus:
//run singleVanBehaviour{trace} for exactly 1 Transit, 1 RemoteFob, 4 Door, 4 Location, 4 Time
run multipleVanBehaviour{trace} for exactly 2 Transit, 2 RemoteFob, 8 Door, 4 Location, 4 Time

```
## Utilities

```alloy
let allVehiclesUnchagedExcept[v] = all vv: Vehicle - v | vv.unchanged 
```
