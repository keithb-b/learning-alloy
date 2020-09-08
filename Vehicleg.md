---
---
# Vehicles and Remote Control Fobs
```alloy
module Vehicle

open Location
open Door
open Zone
```
## Vehicles
This `sig` models the structure of vehicles in general. A specific kind of vehicle should extend this and constrain

* `locations` the places that a `Door` could be
* `zones` how `Door`s are organised for locking and unlocking
* `locationsByZone` assign each `Location` to a `Zone`
* `unlockEffects` the collection of `Zone`s that will be effected by the next unlock command

appropriately for the behaviour of that kind of vehicle.

```alloy
abstract sig Vehicle{
    //structural relations
    ,locations: some Location
    ,zones: some Zone
    ,locationsByZone: zones one -> some locations
    ,fob: disj one RemoteFob
    ,doorAtLocation: locations one -> one Door
    //derived realations
    ,doors: some Door
    ,doorsInZone: zones one -> some doors
    //state
    ,var disj lockedDoors, unlockedDoors : doors
    ,var unlockEffects: set Zone
}{
```
Idiom: `Location.doorAt = doorAt[Location]` and since we join the `doorAt` relation with the whole set of `Location`s, we get the set of all the `Door`s at all the `locations` on this `Vehicle` 

```alloy
    doors = Location.doorAtLocation
    doors = lockedDoors + unlockedDoors
    doorsInZone = locationsByZone.doorAtLocation
}


```
### Actions
```alloy
pred Vehicle::lockCommanded{
    lockedDoors' = doors
}

pred Vehicle::unlockCommanded{
    this.doorsInZone[this.unlockEffects] in this.unlockedDoors'
}

pred Vehicle::unchanged{
    this.lockedDoors' = this.lockedDoors
}

```
### Observations
```alloy
pred Vehicle::allDoorsLocked{
    this.lockedDoors = this.doors
} 

pred Vehicle::allDoorsUnlocked{
    this.unlockedDoors = this.doors
}

pred Vehicle::peopleDoorsUnlockedOnly{
    this.unlockedDoors = this.doorsInZone[People] 
}

pred Vehicle::lockStatusUnchanged{
    lockedDoors' = lockedDoors //unlockedDoors implicitly unchanged
}
```

## Remote Fobs
Vehicles are locked and unlocked using their paired wireless fob. Must be in the same file, as a circular dependency.
```alloy
sig RemoteFob{
    vehicle: disj one Vehicle
}

```
### Facts
Idiom: we say that the `fob` relation (`Vehicle -> RemoteFob`) joined with the `vehicle` relation (`RemoteFob -> Vehicle`) is a subset of the `iden`tity relation.

```alloy
fact FobVehiclePairing{
    fob.vehicle in iden   
}

```
### Observations
```alloy
pred Vehicle::allLocked{
    lockedDoors = doors
}

pred Vehicle::allUnlocked{
    unlockedDoors = doors
}

```
### Actions
```alloy
pred RemoteFob::unlockCommanded{
   this.vehicle.unlockCommanded
}


pred RemoteFob::lockCommanded{
   this.vehicle.lockCommanded
}
   
```
