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
This `sig` models the structure of vehicles in general. A specific kind of vehicle should extend this and constrain:

* `locations` 
* `zones`
* `locationsByZones` 
* `unlockEffects`

appropriately for the behaviour of that kind of vehicle.

```alloy
abstract sig Vehicle{
    ,locations: some Location
    ,doors: some Door
    ,doorAt: locations one -> one doors
    ,fob: disj one RemoteFob
    ,zones: some Zone
    ,locationsByZones: zones one -> some locations
    ,doorsInZone: zones one -> some doors
    ,unlockEffects: set Zone
}{
    doors = Location.doorAt
    doors.lockState = {Locked} or doors.lockState = {Unlocked}
    doorsInZone = locationsByZones.doorAt
}


```
### Actions
```alloy
pred Vehicle::lockCommanded{
    all d: this.doors |
        d.lockCommanded
}

pred Vehicle::unlockCommanded{
    all d: this.doors | 
        d in this.doorsInZone[this.unlockEffects] implies 
            d.unlockCommanded 
        else
            d.unchanged
}

pred Vehicle::unchanged{
    all d: this.doors |
        d.unchanged
}

```
### Observations
```alloy
pred Vehicle::allDoorsLocked{
    no {Unlocked} & this.doors.lockState
} 

pred Vehicle::allDoorsUnlocked{
    no {Locked} & this.doors.lockState
}

pred Vehicle::peopleDoorsUnlockedOnly{
    let peopleDoors = this.doorsInZone[People] | {
        peopleDoors.lockState' = {Unlocked}
        all d: this.doors - peopleDoors | d.unchanged
    }
}

```

## Remote Fobs
Vehicles are locked and unlocked using their paired wireless fob.

```alloy
sig RemoteFob{
    vehicle: disj one Vehicle
}

```
### Facts
Slightly tricky stuff here: we say that the `fob` relation (`Vehicle -> RemoteFob`) joined with the `vehicle` relation (`RemoteFob -> Vehicle`) is a subset of the `iden`tity relation.

```alloy
fact FobVehiclePairing{
    fob.vehicle in iden   
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
