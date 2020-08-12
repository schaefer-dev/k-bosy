 KBoSy

create xcodeproj from swift package using `swift package generate-xcodeproj`


# Dependencies
- adjust directories in Sources/Utils/utils.swift and Sources/KBoSy/main.swift
- set environment variable `EAHYPER\_SOLVER\_DIR="...../eahyper/LTL\_SAT\_solver"`

# Linux
- support for aalta backend in EAHyper, huge performance benefits due to optimzation for early termination


## Automata Info Input
- Specifies which APs are observable and which are not (every AP has to be contained in either of those sets)
- Specifies KLTL specification that is synthesised by BoSy after knowledge has been abstracted away
- Specifies Output APs that are under control by the later BoSy-synthesized strategy
- May specify candidate states for Knowledge terms which would skip the internal model checking to determine this candidate states algorithmically

## Automata Graph Input
- Needs to mark at least one state as initial state
- Graph has to be complete, ie. at any point in time every state has to have at least one applicable transition.
- Transition Conditions have to be given in DNF Form.
- All APs have to be specified in AutomataInfo File beforehand.
