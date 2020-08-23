---
---
```alloy
module Lock

abstract sig LockState{}
```
This could have been an `enum`, but that doesn't allow for `Locked` and `Unlocked` to have different styling on the visualiser. Which I'd like.

```alloy
one sig Locked extends LockState{}
one sig Unlocked extends LockState{}

```
