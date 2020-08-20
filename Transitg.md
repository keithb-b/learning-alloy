---
---
```alloy
module Transit

open Vehicle
open Location   

sig Transit extends Vehicle {
}{
   locations = //this works, but I can't wite a predicate which fails if this is "in" rather than "="
      Rear
    + PassengerSide
    + DriverFront
    + PassengerFront
}
```
