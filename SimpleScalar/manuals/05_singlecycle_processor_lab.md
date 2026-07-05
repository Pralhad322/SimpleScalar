# Lab 4: Educational Single-Cycle Processor Model

## Objective

This lab uses the course simulator `sim-singlecycle` to demonstrate a single-cycle execution model. The simulator executes instructions functionally like `sim-safe`, but it charges exactly one simulated cycle per committed instruction.

Important relationship:

```text
CPI = total cycles / total instructions
```

For this educational single-cycle model:

```text
sim_cycle = sim_num_insn
sim_CPI = 1.0000
```

## Setup

Run from the cloned repository root:

```bash
cd /path/to/SimpleScalar
make clean
make config-pisa
make
mkdir -p labs
cp tests-pisa/bin.little/test-math labs/
```

Confirm that `sim-singlecycle` exists:

```bash
ls sim-singlecycle
```

## Part 1: Run the Single-Cycle Simulator

Run:

```bash
./sim-singlecycle -redir:sim labs/test_math_singlecycle.out labs/test-math
```

Extract the main statistics:

```bash
grep -E "sim_num_insn|sim_cycle|sim_IPC|sim_CPI" labs/test_math_singlecycle.out
```

Record:

| Program | Instructions | Cycles | IPC | CPI |
| --- | ---: | ---: | ---: | ---: |
| `test-math` | | | | |

## Part 2: Explain the Result

Answer:

1. Why is `sim_CPI` equal to 1.0000?
2. Why is `sim_cycle` equal to `sim_num_insn`?
