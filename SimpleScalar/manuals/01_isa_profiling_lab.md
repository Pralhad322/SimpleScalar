# Lab 1: ISA Profiling

## Introduction

In this exercise, students run pre-compiled benchmarks to analyze the distribution of instructions they execute. The `sim-profile` simulator is used to collect instruction class statistics. The goal is to understand the characteristics of different programs and compare the PISA and Alpha ISAs.

All commands in this lab should be run from the cloned repository root.

```bash
cd /path/to/SimpleScalar
```

## Part 1: Profiling Alpha Benchmarks

### Step 1: Configure the Simulator for Alpha

Clean the directory:

```bash
make clean
```

Configure for Alpha:

```bash
make config-alpha
```

Build the simulators:

```bash
make
```

### Step 2: Run the Benchmark Suite

Execute the following commands. After each run, find `sim_num_insn` and the `sim_inst_class_prof` section in the output.

```bash
./sim-profile -iclass benchmarks/anagram.alpha benchmarks/words < benchmarks/anagram.in
```

```bash
./sim-profile -iclass benchmarks/compress95.alpha < benchmarks/compress95.in
```

```bash
./sim-profile -iclass benchmarks/go.alpha 50 9 benchmarks/2stone9.in
```

```bash
./sim-profile -iclass benchmarks/cc1.alpha -O benchmarks/1stmt.i
```

In the current repository, `benchmarks/` is directly under the repository root.

### Step 3: Data Collection and Analysis

Record your results in Table 1.

| Benchmark | Total Insts | Load % | Store % | Uncond. Branch % | Cond. Branch % | Integer Compute % | Floating Pt. Compute % |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `anagram.alpha` | | | | | | | |
| `go.alpha` | | | | | | | |
| `compress95.alpha` | | | | | | | |
| `cc1.alpha` | | | | | | | |

Answer these questions for each benchmark:

1. Is the benchmark memory intensive or computation intensive?
2. Is the benchmark mainly using integer computation or floating-point computation?
3. What percentage of instructions are conditional branches?
4. On average, how many instructions execute between conditional branches?

Use:

```text
instructions between conditional branches = 100 / conditional branch percentage
```

## Part 2: Comparing Alpha and PISA ISAs

This part executes the same smaller test programs on both Alpha and PISA configurations.

### Section A: Run Alpha Test Programs

Ensure the simulator is still configured for Alpha. If needed:

```bash
make clean
make config-alpha
make
```

Run:

```bash
./sim-profile -iclass tests-alpha/bin/test-math
./sim-profile -iclass tests-alpha/bin/test-fmath
./sim-profile -iclass tests-alpha/bin/test-llong
./sim-profile -iclass tests-alpha/bin/test-printf
```

Record the results in Table 2.

| Benchmark | Total Insts | Load % | Store % | Uncond. Branch % | Cond. Branch % | Integer Compute % | Floating Pt. Compute % |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `test-math` | | | | | | | |
| `test-fmath` | | | | | | | |
| `test-llong` | | | | | | | |
| `test-printf` | | | | | | | |

### Section B: Run PISA Test Programs

Reconfigure for PISA:

```bash
make clean
make config-pisa
make
```

Run:

```bash
./sim-profile -iclass tests-pisa/bin.little/test-math
./sim-profile -iclass tests-pisa/bin.little/test-fmath
./sim-profile -iclass tests-pisa/bin.little/test-llong
./sim-profile -iclass tests-pisa/bin.little/test-printf
```

Record the results in Table 3.

| Benchmark | Total Insts | Load % | Store % | Uncond. Branch % | Cond. Branch % | Integer Compute % | Floating Pt. Compute % |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `test-math` | | | | | | | |
| `test-fmath` | | | | | | | |
| `test-llong` | | | | | | | |
| `test-printf` | | | | | | | |

## Final Analysis

Compare the Alpha and PISA results. Create a histogram using MATLAB, Excel, Python, or another tool comparing a key metric, such as total instruction count for each test program across the two ISAs.

What can you conclude about the two ISAs from your data and plot? For instance, does one ISA accomplish the same task with fewer instructions?
