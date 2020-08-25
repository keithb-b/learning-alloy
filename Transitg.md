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
