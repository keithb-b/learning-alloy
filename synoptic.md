---
---
# Behaviour of a vehicle locking system

## Doors and Locations on the Vehicle, Locks
```alloy
sig Door{
   var lockState: LockState
}{
}

//actions
pred Door::unlockCommanded{
    this.lockState' = Unlocked
}

pred Door::lockCommanded{
    this.lockState' = Locked
}

pred Door::unchanged{
    this.lockState' = this.lockState
}

//observations
pred  Door::locked{
    this.lockState = Locked
}

pred Door::unlocked{
    this.lockState = Unlocked
}

enum Purpose {ForPeople, ForCargo} 
abstract sig Location {
    ,purpose: one Purpose
}

enum Side {Driver, Passenger}
enum Place {Front, Sliding}
abstract sig PositionalLocation extends Location{
    ,side: one Side
    ,position: one Place
}

one sig DriverFront extends PositionalLocation{}{
    side = Driver
    position = Front
    purpose = ForPeople
}

one sig PassengerFront extends PositionalLocation{}{
    side = Passenger
    position = Front
    purpose = ForPeople
}

one sig PassengerSide extends PositionalLocation{}{
   side = Passenger
   position = Sliding
   purpose = ForCargo
}


one sig Rear extends Location{}{
   purpose = ForCargo
}


abstract sig LockState{}
```
This could have been an `enum`, but that doesn't allow for `Locked` and `Unlocked` to have different styling on the visualiser. Which I'd like.

```alloy
one sig Locked extends LockState{}
one sig Unlocked extends LockState{}

```
# Vehicles and Remote Control Fobs

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
Concrete example drawn from 2019 Ford Transit users handbook.

```alloy
sig Transit extends Vehicle {
}{
   locations = //this works, but I can't wite a predicate which fails if this is "in" rather than "="
      Rear
    + PassengerSide
    + DriverFront
    + PassengerFront

   zones = 
      People +
      RearCargo +
      OtherCargo

   locationsByZones = 
      People -> DriverFront +
      People -> PassengerFront +
      RearCargo -> Rear +
      OtherCargo -> PassengerSide

    unlockEffects = People or unlockEffects = People + Cargo
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
## Zonal Locking

```alloy
   
abstract sig Zone{}

one sig People extends Zone{}

abstract sig Cargo extends Zone{}

one sig RearCargo extends Cargo{}

one sig OtherCargo extends Cargo{}


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

pred aDoorIsInAZone{
   all d: Door |
      one z: Zone |
          one v: Vehicle |
             d in v.doorsInZone[z]
}
   
pred aPeopleZoneContainsTheDoorsForPeople{
   all v: Vehicle |
      all l: v.locations |
          l.purpose in ForPeople => some z: v.zones | z in People and l in v.locationsByZones[z]
}

pred aCargoZoneContainsTheDoorsForCargo{
   all v: Vehicle |
      all l: v.locations |
          l.purpose in ForCargo => some z: v.zones | z in Cargo and l in v.locationsByZones[z]
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

```alloy

pred doorsInAZoneHaveTheSameLockState{
    all v: Vehicle |
        all z: v.zones | 
           no v.doorsInZone[z].lockState :> Locked or
           no v.doorsInZone[z].lockState :> Unlocked
}

pred doorsChangeStateOnlyOnFobCommands{
    all f: RemoteFob |
        let v = f.vehicle |
            all d: v.doors |
               d.unchanged until f.unlockCommanded or f.lockCommanded        
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
    all d: Door |
            d.locked
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
        all d: Door | d.unlocked
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
