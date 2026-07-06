# Lab 0: SimpleScalar Setup and Orientation

## Purpose

This lab prepares students to build and run the SimpleScalar simulators used in the course. Students will verify the repository layout, build the simulators for PISA and Alpha, and run a small test program.
## Repository Layout

After cloning the course repository, the repository root itself is the SimpleScalar working directory. If the repository is cloned as `SimpleScalar`, the layout is:
```bash
SimpleScalar/
  benchmarks/
  config/
  labs/
  scripts/
  SimpleScalar/
    experiments/
  tests-alpha/
  tests-pisa/
  sim-fast.c
  sim-safe.c
  sim-profile.c
  sim-bpred.c
  sim-outorder.c
  sim-singlecycle.c
  Makefile
```

There is no extra nested `simplesim-3.0/` directory in this repository. Run the commands in these manuals from the cloned repository root unless a lab explicitly says to enter `labs/`.
## Simulator Overview

| Simulator | Purpose |
| --- | --- |
| `sim-fast` | Fast functional simulation with minimal checking. |
| `sim-safe` | Functional simulation with additional safety checks. |
| `sim-profile` | Instruction and address profiling. |
| `sim-cache` | Cache hierarchy simulation. |
| `sim-bpred` | Branch predictor simulation. |
| `sim-outorder` | Detailed out-of-order processor timing simulation. |
| `sim-singlecycle` | Educational single-cycle timing model added for this course. |

## Part A: Build for PISA

Open a terminal in the cloned repository root:
```bash
cd /path/to/SimpleScalar
```

Clean any old build files:
```bash
make clean
```

Configure for PISA:
```bash
make config-pisa
```

Compile the simulators:
```bash
make
```

Check that simulator executables were created:
```bash
ls sim-fast sim-safe sim-profile sim-bpred sim-outorder sim-singlecycle
```

Run a quick PISA test:
```bash
./sim-safe tests-pisa/bin.little/test-math
```

## Part B: Build for Alpha

Clean the previous build:
```bash
make clean
```

Configure for Alpha:
```bash
make config-alpha
```

Compile again:
```bash
make
```

Run a quick Alpha test:
```bash
./sim-safe tests-alpha/bin/test-math
```

## Part C: Getting Help From a Simulator

Every simulator supports a help option:
```bash
./sim-profile -h
./sim-outorder -h
./sim-bpred -h
```

Use the help output to confirm the option names used in later labs.
