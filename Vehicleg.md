---
---
```alloy

module Vehicle

open Location
open Door

abstract sig Vehicle{
     ,locations: some Location
     ,doors: some Door
     ,doorAt: locations one -> one doors
}{
    doors = Location.doorAt
    doors.lockState = {Locked} or doors.lockState = {Unlocked}
}

// actions
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

//observations
pred Vehicle::allDoorsLocked{
    no {Unlocked} & this.doors.lockState
} 

pred Vehicle::allDoorsUnlocked{
    no {Locked} & this.doors.lockState
}
```
