# Lab 0: SimpleScalar Setup and Orientation

## Purpose

This lab prepares students to use SimpleScalar for processor architecture experiments. By the end of the session, students should be able to build the simulator, identify the major simulator tools, switch between Alpha and PISA targets, and run a simple test program.

## Learning Outcomes

After completing this lab, students will be able to:

- Explain the role of functional and timing simulation.
- Identify the difference between Alpha and PISA targets.
- Build SimpleScalar for a selected target ISA.
- Run a simulator executable and redirect output to a file.
- Locate benchmark binaries, inputs, configuration files, and simulator reports.

## Background

SimpleScalar is a computer architecture simulation toolset. It can run compiled programs for simulated target machines and report statistics about instruction execution, memory behavior, branch prediction, and pipeline performance.

The two target ISAs used in this course are:

- Alpha: a 64-bit RISC instruction set used for larger benchmark experiments.
- PISA: a portable MIPS-like instruction set commonly used for teaching experiments.

SimpleScalar includes several simulator executables:

| Simulator | Purpose |
| --- | --- |
| `sim-fast` | Fast functional simulation with minimal checking. |
| `sim-safe` | Functional simulation with additional safety checks. |
| `sim-profile` | Instruction and address profiling. |
| `sim-cache` | Cache hierarchy simulation. |
| `sim-bpred` | Branch predictor simulation. |
| `sim-outorder` | Detailed out-of-order processor timing simulation. |

## Required Files

Students need the extracted lab package:

```text
SimpleScalar/
  benchmarks/
  simplesim-3.0/
```

If the package is still zipped, extract it first:

```bash
unzip SimpleScalar.zip
```

## Part A: Build for PISA

Open a terminal in the simulator source directory:

```bash
cd SimpleScalar/simplesim-3.0
```

Clean any old build files:

```bash
make clean
```

Configure for PISA:

```bash
make config-pisa
```

Compile the simulator:

```bash
make
```

Check that simulator executables were created:

```bash
ls sim-fast sim-profile sim-outorder
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
```

Students should record one option from `sim-profile -h` and one option from `sim-outorder -h` that they expect to use in later labs.

## Checkpoint Questions

1. What is the difference between functional simulation and timing simulation?
2. Which simulator is most appropriate for instruction class profiling?
3. Which simulator is most appropriate for pipeline and superscalar experiments?
4. Why must the directory be cleaned before switching from one target ISA to another?

## Submission

Submit a short setup report containing:

- The target ISA builds completed.
- A screenshot or copied terminal output showing one successful PISA run.
- A screenshot or copied terminal output showing one successful Alpha run.
- Answers to the checkpoint questions.

## Common Problems

| Problem | Likely cause | Fix |
| --- | --- | --- |
| `make: *** No rule to make target` | Wrong directory | Run commands inside `SimpleScalar/simplesim-3.0`. |
| `command not found: ./sim-safe` | Build did not finish | Run `make` and check for errors. |
| Program binary does not run | Simulator built for the wrong ISA | Rebuild using `make clean`, then the correct `make config-*` command. |
| Paths do not match the manual | Different extraction location | Keep the same relative paths from `SimpleScalar/`. |
