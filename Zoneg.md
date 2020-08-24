---
---
```alloy
abstract sig Zone{}

one sig People extends Zone{}

abstract sig Cargo extends Zone{}

one sig RearCargo extends Cargo{}

one sig OtherCargo extends Cargo{}

```
