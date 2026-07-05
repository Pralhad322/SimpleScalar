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
3. Does `sim-singlecycle` measure a real hardware clock period in ps or ns?

## Part 3: Add Clock-Time Calculation

SimpleScalar reports simulated cycles. It does not measure physical clock period. To estimate CPU time, the instructor must provide a datapath delay model.

Example stage delays:

| Stage | Delay |
| --- | ---: |
| Instruction fetch | 250 ps |
| Decode/register read | 150 ps |
| Execute/ALU | 200 ps |
| Memory access | 250 ps |
| Write back | 100 ps |

For a single-cycle processor, one instruction must complete all stages in one clock cycle:

```text
single-cycle clock time = 250 + 150 + 200 + 250 + 100
                        = 950 ps
```

Then:

```text
CPU time = instruction count x CPI x clock time
```

Use your measured instruction count:

```text
single-cycle CPU time = sim_num_insn x 1.0000 x 950 ps
```

## Part 4: Optional Custom Program

After completing the compile-program lab, compile `labs/hello.c`:

```bash
toolchain/sslittle-na-sstrix/bin/gcc -O2 -static -o labs/hello.pisa labs/hello.c
```

Run it:

```bash
./sim-singlecycle -redir:sim labs/hello_singlecycle.out labs/hello.pisa
grep -E "sim_num_insn|sim_cycle|sim_IPC|sim_CPI" labs/hello_singlecycle.out
```

Compare the instruction count of `hello.pisa` with `test-math`.
