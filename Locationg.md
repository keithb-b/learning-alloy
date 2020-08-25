---
---
```alloy
module Location

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


```
