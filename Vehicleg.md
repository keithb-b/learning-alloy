---
---
# Vehicles and Remote Control Fobs
```alloy
module Vehicle

open Location
open Door
```
## Vehicles
This `sig` models the structure of vehicles in general. A specific kind of vehicle should extend this and constrain `locations` appropriately.

```alloy
abstract sig Vehicle{
    ,locations: some Location
    ,doors: some Door
    ,doorAt: locations one -> one doors
    ,fob: disj one RemoteFob
}{
    doors = Location.doorAt
    doors.lockState = {Locked} or doors.lockState = {Unlocked}
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
        d.unlockCommanded
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
