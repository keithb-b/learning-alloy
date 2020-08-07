open util/relation
open util/time as time

//structure
abstract sig Vehicle{
     doors: disj set Door
    ,doorAt:  Location one -> one Door
    ,locations: set Location
}

fun Vehicle::allDoorsOf: set Door{
    ran[this.doorAt] //was it really worth abbreviating "range"?
}     

sig Transit extends Vehicle {
}{
   locations in
      Rear
    + PassengerSide
    + DriverFront
    + PassengerFront
}

sig Door{
    on: one Vehicle
   ,whenInLockState: LockState -> one Time
}{ 
       time/ordering/first in {t: Time | t = whenInLockState[Locked]}
       time/ordering/first not in {t: Time | t = whenInLockState[Unlocked]}
}

abstract sig Location {} 
one sig Rear extends Location {}

enum Side {Driver, Passenger}
enum Place {Front, Sliding}
abstract sig PositionalLocation extends Location{
     side: Side
    ,position: Place
}

one sig DriverFront extends PositionalLocation{}{
    side = Driver
    position = Front
}

one sig PassengerFront extends PositionalLocation{}{
    side = Passenger
    position = Front
}

one sig PassengerSide extends PositionalLocation{}{
   side = Passenger
   position = Sliding
}

//state
enum LockState{
     Locked
    ,Unlocked
}

pred Door::unlockedBetween[t, t' : Time]{
    t' in { s: Time | s = this.whenInLockState[Unlocked]}
}

//facts
fact doorsAreOnTheirVehicle{
    all d: Door |
        all v: Vehicle |
            d in v.doors <=> v = d.on 
}

fact doorsAreLocatedOnOneVehicleOnly{
    all d: Door |
        all v, u: Vehicle | 
            d in v.doors and d in u.doors <=> v = u
}

fact doorsAreInOneLocationOnly{
    all v: Vehicle |
        all l, m: v.locations | 
                v.doorAt[l] = v.doorAt[m] <=> l = m
}

fact locationsOnVehicles{
    all l: Location |
        some v: Vehicle |
            l in v.locations
}

//Checks
//The below should be true of the above:

pred doorsOnAVehicle {
    all d: Door |
        one v: Vehicle |
            d in v.doors
}

pred doorsOnTheirVehicle{
    all d: Door |
            d in d.on.doors
}

pred doorsInALocation{
    all d: Door |
        one v: Vehicle |
            one l: v.locations |
                d = v.doorAt[l]
}

pred doorsInOneLocationOnly{
    all v: Vehicle |
        all d: v.doors |
            #(v.doorAt :> d) = 1
}

pred doorsAtLocationsOnTheirVehicle{
    all d: Door |
        all l: Location |
            d = d.on.doorAt[l] => l in d.on.locations
}

pred validStructure{
    doorsOnAVehicle
    doorsOnTheirVehicle
    doorsInALocation
    doorsInOneLocationOnly
    doorsAtLocationsOnTheirVehicle
}

pred doorsBeginDoubleLocked{
    //Can't use domain restriction with enums, it looks like.
    //Thus a set comprehension. Is that irksome enough to use a one sig instead?
	all d: Door |
       time/ordering/first in {t: Time | t = d.whenInLockState[Locked]}
}

pred doorsHaveOnlyOneStateAtATime{
    all d: Door |
        all s, s': LockState |
            s != s' => d.whenInLockState[s] != d.whenInLockState[s']
}

pred doorStates{
    doorsBeginDoubleLocked
    doorsHaveOnlyOneStateAtATime 
}

check{
    validStructure
    doorStates
} for 1 Transit, 4 Door, 4 Location, 2 Time expect 0

//As  we should see demonstrated thus:

pred aTransit{
    0 < #Transit
}

run aTransit for 1 Transit, 4 Door, 4 Location, 2 Time
