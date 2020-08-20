---
---
```alloy
module Location

abstract sig Location {} 
one sig Rear extends Location {}

enum Side {Driver, Passenger}
enum Place {Front, Sliding}
abstract sig PositionalLocation extends Location{
    ,side: Side
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
```