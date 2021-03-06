[Benchmark files can be found here. Includes both dot graph files and also automata info files.](https://schaefer-dev.de/kbosy-specs)

optionally create xcodeproj from swift package using `swift package generate-xcodeproj` to work with XCode


# Setup

## Dependencies
- [EAHyper](https://github.com/reactive-systems/eahyper) (AAlta and PLTL supported).
- Optionally [BoSy (Swift)](https://github.com/reactive-systems/bosy/tree/master/Sources) to synthesize strategies from the LTL specifications generated by KBoSy.

## Environmet Variables
- set environment variable `EAHYPER_SOLVER_DIR="...../eahyper/LTL_SAT_solver"`
- set environment variable `KBOSY_EAHYPER_BINARY="..../eahyper/eahyper_src/eahyper.native"`
- set environment variable `KBOSY_OUTPUT_DIR`
- set environment variable `KBOSY_ROOT_DIR` to absolute path of KBoSy's root directory
- optionally set environment variable `KBOSY_INPUT_DIR` to directory to avoid the need to specify absolute paths for both specification, input file and dot-graph
- adjust BoSy Directory in `bosy_run.sh` script if it is desired to call BoSy automatically after KBoSy for LTL synthesis

## Linux
- support for Aalta backend in EAHyper, very significant performance benefits due to optimzation for early termination (reports in thesis)
- Build and run scripts require at least Swift 5.2.4 to be installed


# Input

## Automata Info Input
- Specifies which APs are observable and which are not (every AP has to be contained in either of those sets)
- Specifies KLTL specification that is synthesised by BoSy after knowledge has been abstracted away
- Specifies Output APs that are under control by the later BoSy-synthesized strategy
- May specify candidate states for Knowledge terms which would skip the internal model checking to determine this candidate states algorithmically
- Examples given in [Benchmark Repo](https://schaefer-dev.de/kbosy-specs)

## Automata Graph Input
- Needs to mark at least one state as initial state
- Graph has to be complete, ie. at any point in time every state has to have at least one applicable transition.
- Transition Conditions have to be given in DNF Form.
- All APs have to be specified in AutomataInfo File beforehand.
- Examples given in [Benchmark Repo](https://schaefer-dev.de/kbosy-specs)

## Most used Arguments
- `-i` specifies input automata file. Can be given as relative path starting from the environment variable `KBOSY_INPUT_DIR` which may be set.
- `-d` specifies dot graph of the environmen behavior. Can be given as relative path starting from the environment variable `KBOSY_INPUT_DIR` which may be set.
- `--benchmark` to output performance breakdown of different tasks performed by KBoSy.
- `--synthesize` to automatically forward the resulting LTL synthesis task to BoSy.
- `--aalta` to use Aalta satifiability checker instead of default PLTL. Results in significant performance improvements as reported in my thesis.
