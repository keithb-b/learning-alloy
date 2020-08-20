---
---
```alloy
module Door

open Lock

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
```
