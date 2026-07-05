# Instructor Guide: SimpleScalar Computer Architecture Labs

## Course Fit

These labs are suitable for a computer architecture course after students have studied ISA concepts, pipelining, hazards, branch behavior, and superscalar execution.

Suggested grouping:

- 2 students per group for lab execution.
- Individual written reflection if assessment requires independent understanding.

Suggested duration:

- Setup and orientation: 1 lab hour.
- ISA profiling: 2 lab hours.
- Processor design lab: 2 lab hours.
- Home assignment: outside class or 2 additional lab hours.

## Before the Lab

Prepare one tested copy of the SimpleScalar package with this layout:

```text
SimpleScalar/
  benchmarks/
  simplesim-3.0/
```

Verify both targets build:

```bash
cd SimpleScalar/simplesim-3.0
make clean
make config-pisa
make
./sim-safe tests-pisa/bin.little/test-math
make clean
make config-alpha
make
./sim-safe tests-alpha/bin/test-math
```

For Lab 2 and the home assignment, rebuild PISA before class:

```bash
make clean
make config-pisa
make
```

## Expected Processor Design Results

The exact values may vary slightly by simulator version, host compiler, and local patches. For the package used to prepare the original manuals, the expected IPC values were:

| Config | Description | Expected IPC |
| --- | --- | ---: |
| A | scalar in-order, one functional unit each | 0.5071 |
| B | scalar out-of-order, one functional unit each | 0.5184 |
| C | scalar in-order, four functional units each | 0.5071 |
| D | scalar out-of-order, four functional units each | 0.5184 |
| E | 4-wide out-of-order, one functional unit each | 0.5184 |
| F | 4-wide out-of-order, four functional units each | 1.3035 |
| G | configuration F with RUU increased from 8 to 16 | 1.3245 |

Use these as reference values, not as the only acceptable answers. Students should be graded mainly on correct method, correct extraction of their measured values, and correct reasoning.

## Key Teaching Points

### Lab 0

Students should understand that the simulator executable must match the target binary ISA. A PISA-built simulator should run PISA binaries, and an Alpha-built simulator should run Alpha binaries.

### Lab 1

Important concepts:

- Instruction count differs across ISAs for the same high-level program.
- Instruction mix affects processor design choices.
- Memory-intensive programs stress cache and memory hierarchy.
- Branch-heavy programs stress branch prediction and control hazard handling.
- Floating-point programs need appropriate FP resources.

Students often confuse total instruction count with runtime. Remind them that runtime also depends on CPI, clock period, memory behavior, branch prediction, and microarchitecture.

### Lab 2

Important concepts:

- Configuration A is scalar and in-order.
- Configuration B permits out-of-order issue, but is still limited by a narrow front end.
- A small IPC improvement from A to B is expected for `test-math`.
- Forwarding evidence should come from a RAW dependency in the pipeline trace.
- In-order commit is needed for precise architectural state and precise exceptions.

### Home Assignment

Important conclusions:

- Adding functional units alone does not help if issue width is 1.
- Widening decode alone or issue alone does not help if the other stage remains narrow.
- A wide pipeline without enough functional units suffers structural bottlenecks.
- The large IPC jump appears only when the front end and execution resources are both widened.
- A larger RUU can improve performance, but with diminishing returns.

## Suggested Rubric

| Component | Marks |
| --- | ---: |
| Correct setup and simulator use | 10 |
| Complete tables and measured statistics | 25 |
| Correct graphs or visual comparisons | 10 |
| Analysis quality and architectural reasoning | 35 |
| Evidence from simulator output or traces | 10 |
| Report clarity and organization | 10 |

## Common Mistakes and How to Respond

| Mistake | Instructor response |
| --- | --- |
| Student runs Alpha binary with PISA simulator | Ask them to rebuild or switch to matching binary path. |
| Student reports `sim_num_insn` but ignores instruction class percentages | Point them to `sim_inst_class_prof`. |
| Student edits the wrong configuration file | Ask for `grep` output of the parameter values from the file they used. |
| Student changes multiple parameters at once | Require one-factor-at-a-time experiments for bottleneck analysis. |
| Student says commit reorders instructions | Clarify that execution may occur out of order, but commit restores program order. |
| Student claims more resources always improve performance | Ask them to identify the narrowest pipeline stage. |

## Quick Checks

Use these commands to verify student files:

```bash
grep sim_IPC labs/sim_config*.out
```

```bash
grep -E 'fetch:ifqsize|decode:width|issue:width|issue:inorder|ruu:size|lsq:size|res:' labs/config_*.cfg
```

## Suggested Discussion Questions

1. Why can two processors with the same ISA have very different performance?
2. Why does out-of-order execution need a larger instruction window?
3. What is the difference between a data hazard and a structural hazard?
4. Why is a balanced processor usually better than improving only one component?
5. Why is IPC alone not a complete measure of processor quality?

## Notes on the Reference Site

The manuals were prepared using the same broad experiment themes as the SimpleScalar instructional material hosted by the UMass architecture course site. If the site is unavailable during lab preparation, the local manuals and the simulator help output are sufficient for running the experiments.
