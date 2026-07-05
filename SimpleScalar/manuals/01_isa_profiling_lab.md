# Lab 1: Instruction Set Profiling With SimpleScalar

## Purpose

This lab studies how programs use an instruction set. Students will use `sim-profile` to collect instruction class statistics and compare workloads across Alpha and PISA binaries.

## Learning Outcomes

After completing this lab, students will be able to:

- Run `sim-profile` with instruction class profiling.
- Extract total instruction count and instruction class percentages.
- Identify whether a workload is memory intensive, branch intensive, integer intensive, or floating-point intensive.
- Compare instruction behavior across two ISAs.

## Preparation

Start from the simulator directory:

```bash
cd SimpleScalar/simplesim-3.0
```

For Alpha experiments:

```bash
make clean
make config-alpha
make
```

## Part A: Alpha Benchmark Profiling

Run the following commands and save the output for your report.

```bash
./sim-profile -iclass ../benchmarks/anagram.alpha ../benchmarks/words < ../benchmarks/anagram.in
```

```bash
./sim-profile -iclass ../benchmarks/compress95.alpha < ../benchmarks/compress95.in
```

```bash
./sim-profile -iclass ../benchmarks/go.alpha 50 9 ../benchmarks/2stone9.in
```

```bash
./sim-profile -iclass ../benchmarks/cc1.alpha -O ../benchmarks/1stmt.i
```

In each output, find:

- `sim_num_insn`
- the `sim_inst_class_prof` section

Complete Table 1.

| Benchmark | Total instructions | Load % | Store % | Unconditional branch % | Conditional branch % | Integer compute % | Floating-point compute % |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `anagram.alpha` | | | | | | | |
| `compress95.alpha` | | | | | | | |
| `go.alpha` | | | | | | | |
| `cc1.alpha` | | | | | | | |

## Part B: Alpha Test Program Profiling

Run these smaller Alpha test programs:

```bash
./sim-profile -iclass tests-alpha/bin/test-math
./sim-profile -iclass tests-alpha/bin/test-fmath
./sim-profile -iclass tests-alpha/bin/test-llong
./sim-profile -iclass tests-alpha/bin/test-printf
```

Complete Table 2.

| Program | Total instructions | Load % | Store % | Unconditional branch % | Conditional branch % | Integer compute % | Floating-point compute % |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `test-math` | | | | | | | |
| `test-fmath` | | | | | | | |
| `test-llong` | | | | | | | |
| `test-printf` | | | | | | | |

## Part C: PISA Test Program Profiling

Rebuild for PISA:

```bash
make clean
make config-pisa
make
```

Run the matching PISA programs:

```bash
./sim-profile -iclass tests-pisa/bin.little/test-math
./sim-profile -iclass tests-pisa/bin.little/test-fmath
./sim-profile -iclass tests-pisa/bin.little/test-llong
./sim-profile -iclass tests-pisa/bin.little/test-printf
```

Complete Table 3.

| Program | Total instructions | Load % | Store % | Unconditional branch % | Conditional branch % | Integer compute % | Floating-point compute % |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| `test-math` | | | | | | | |
| `test-fmath` | | | | | | | |
| `test-llong` | | | | | | | |
| `test-printf` | | | | | | | |

## Analysis Questions

Answer the following using your measured data.

1. Which Alpha benchmark is most memory intensive? Use load and store percentages to justify your answer.
2. Which benchmark or test program has the highest conditional branch percentage?
3. For each Alpha benchmark in Table 1, estimate the average number of executed instructions between conditional branches:

```text
instructions between conditional branches = 100 / conditional branch percentage
```

4. Which test program uses floating-point instructions most heavily?
5. Compare Alpha and PISA for the four test programs. Which ISA executes more total instructions for the same program? Is the trend the same for every program?
6. Create one graph comparing total instruction count for Alpha and PISA test programs.
7. Based on this lab, why is instruction mix important when designing a processor?

## Submission

Submit:

- Tables 1, 2, and 3.
- Answers to the analysis questions.
- One graph comparing Alpha and PISA total instruction counts.
- A short conclusion of 100 to 150 words.
- The simulator output files or pasted output sections used to calculate the table values.

## Report Tip

Do not only report numbers. Explain what the numbers imply. For example, a workload with many loads and stores may be more sensitive to cache and memory hierarchy design, while a workload with many conditional branches may be more sensitive to branch predictor accuracy.
