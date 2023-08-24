## What?
This document is a small collection of notes.
Basically just a brain dump. Feel free to ignore.

# List
Heal on/off
    * Heal outside of Combat on/off
Attack on/off
    * Automatic (smart) Damage over time
Smart Target on/off
Pre-pull on/off
Auto-sprint on/off
Auto-raise on/off
Auto-shield on/off
Auto-Esuna on/off
Healing priority:
    Tank
    Healers
    DPS
Esuna Pririty:
    Tank
    Healers
    DPS

Esuna vs Heal HP Percentage:
Default: Esuna first if > 50% hp



## Tank OverHeal

## Party OverHeal

## Smart Target
    Used within Targeting method.
    * Entity Filter
        * Lowest HP
        * Alive
        * Attackable
        * Distance < 30 yalms
    Psudo Code:
        If no target currently selected and Smart Target enabled, then from Entity Filter, select first in-combat enemy.
    Additional options:
        * Frames to wait before selecting a new target.
            * 100
            * 200
            * 300
            * 500
    LUA:
        local currentTarget = MGetTarget()
        
# Sage
* Addersgall available


# Key Binds
[Virtual Key Codes](https://cherrytree.at/misc/vk.htm)

### Modifiers
```
+ shift
! alt
^ ctrl
# windows
```