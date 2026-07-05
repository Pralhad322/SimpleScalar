# Lab 2: Processor Design, Pipelining, and Superscalar Execution

## Purpose

This lab uses `sim-outorder` to compare a simple in-order pipeline with an out-of-order processor. Students will modify simulator configuration files, run timing simulations, and interpret IPC.

## Learning Outcomes

After completing this lab, students will be able to:

- Explain the meaning of decode width, issue width, functional units, RUU size, and LSQ size.
- Configure `sim-outorder` for in-order and out-of-order execution.
- Use IPC to compare processor designs.
- Use a pipeline trace to reason about data forwarding and RAW hazards.
- Explain why out-of-order processors still commit instructions in program order.

## Preparation

Use the PISA build for this lab:

```bash
cd SimpleScalar/simplesim-3.0
make clean
make config-pisa
make
cd ..
```

Create a lab workspace:

```bash
mkdir -p labs
cp simplesim-3.0/config/default.cfg labs/
cp simplesim-3.0/tests-pisa/bin.little/test-math labs/
```

If students are already inside the `simplesim-3.0` directory, use this shorter version:

```bash
mkdir -p labs
cp config/default.cfg labs/
cp tests-pisa/bin.little/test-math labs/
```

## Configuration Parameter Reference

| Parameter | Meaning |
| --- | --- |
| `-fetch:ifqsize` | Instruction fetch queue size. |
| `-decode:width` | Number of instructions decoded per cycle. |
| `-issue:width` | Maximum number of instructions issued per cycle. |
| `-issue:inorder` | Whether issue must follow program order. |
| `-ruu:size` | Register update unit size; main instruction window. |
| `-lsq:size` | Load-store queue size. |
| `-res:ialu` | Number of integer ALUs. |
| `-res:imult` | Number of integer multiply/divide units. |
| `-res:memport` | Number of memory ports. |
| `-res:fpalu` | Number of floating-point ALUs. |
| `-res:fpmult` | Number of floating-point multiply/divide units. |

## Performance Demonstration: Single-Cycle vs Pipelined Processor

This short demonstration helps students compare an ideal single-cycle processor and a simulated pipelined processor. CPI alone is not enough for this comparison because the two processors have different clock cycle times.

Important idea:

```text
CPI = total cycles / total instructions
IPC = total instructions / total cycles
CPI = 1 / IPC
CPU time = instruction count x CPI x clock cycle time
```

SimpleScalar reports instruction counts and simulated cycles. It does not report physical clock cycle time in ps or ns. Clock cycle time must be calculated from an assumed datapath delay model.

### Part 0A: Single-Cycle Processor Model

A single-cycle processor completes every instruction in one long clock cycle. Therefore:

```text
single-cycle CPI = 1.0
single-cycle cycles = instruction count
```

SimpleScalar does not directly model a true single-cycle datapath in `sim-outorder`. Use `sim-profile` only to count the number of executed instructions.

From inside `simplesim-3.0/labs`, run:

```bash
../sim-profile -iclass -redir:sim single_cycle_profile.out ./test-math
```

Check the instruction count:

```bash
grep sim_num_insn single_cycle_profile.out
```

For a single-cycle processor:

```text
total cycles = total instructions
CPI = total cycles / total instructions = 1.0
```

The single-cycle clock period must be long enough for the slowest instruction to pass through all datapath stages in one cycle. If the instructor provides the following delay model:

| Datapath stage | Delay |
| --- | ---: |
| Instruction fetch | 250 ps |
| Decode/register read | 150 ps |
| Execute/ALU | 200 ps |
| Memory access | 250 ps |
| Write back | 100 ps |

Then:

```text
single-cycle clock time = 250 + 150 + 200 + 250 + 100
                        = 950 ps
```

Note: use `-redir:sim single_cycle_profile.out` instead of shell redirection with `>`. SimpleScalar simulator statistics may not be captured correctly by ordinary shell output redirection.

If the course package includes the custom `sim-singlecycle` simulator, students can measure the educational single-cycle counters directly:

```bash
../sim-singlecycle -redir:sim sim_singlecycle.out ./test-math
grep -E "sim_num_insn|sim_cycle|sim_IPC|sim_CPI" sim_singlecycle.out
```

Expected result:

```text
sim_cycle = sim_num_insn
sim_IPC = 1.0000
sim_CPI = 1.0000
```

This simulator is a functional SimpleScalar simulator with one cycle charged per completed instruction. It still does not measure physical clock period.

### Part 0B: Pipelined Processor Model

Now use `sim-outorder` to model a simple scalar in-order pipelined processor.

From inside `simplesim-3.0/labs`, create the pipeline configuration:

```bash
cp default.cfg pipeline.cfg
```

Edit `pipeline.cfg` and set:

```text
-fetch:ifqsize 1
-decode:width 1
-issue:width 1
-issue:inorder true
-ruu:size 8
-lsq:size 8
-res:ialu 1
-res:imult 1
-res:memport 1
-res:fpalu 1
-res:fpmult 1
```

Run the pipelined simulation:

```bash
../sim-outorder -config pipeline.cfg -redir:sim pipeline.out ./test-math
```

Extract the useful statistics:

```bash
grep -E "sim_num_insn|sim_cycle|sim_IPC|sim_CPI" pipeline.out
```

If `sim_CPI` appears, use it directly. If only `sim_IPC` appears, calculate:

```text
pipelined CPI = 1 / sim_IPC
```

The pipelined processor can ideally complete one instruction per cycle after the pipeline fills, but stalls can make CPI greater than 1. The clock period is shorter because each cycle performs only one pipeline stage. Using the same delay model and assuming 20 ps pipeline-register overhead:

```text
pipelined clock time = max(stage delays) + pipeline register overhead
                     = max(250, 150, 200, 250, 100) + 20
                     = 270 ps
```

### Part 0C: Compare Execution Time

Record and calculate:

| Processor model | Instructions | Cycles | CPI | Clock time | CPU time |
| --- | ---: | ---: | ---: | ---: | ---: |
| Ideal single-cycle | from `sim_num_insn` | same as instructions | 1.00 | assumed/calculated | `IC x 1.00 x clock time` |
| Simulated pipelined in-order | from `sim_num_insn` | from `sim_cycle` | from `sim_CPI` | assumed/calculated | `IC x CPI x clock time` |

Example using measured pipeline values:

```text
Instruction count = 213598
Pipelined cycles = 224224
Pipelined CPI = 1.0497
Single-cycle clock time = 950 ps
Pipelined clock time = 270 ps

Single-cycle CPU time = 213598 x 1.0 x 950 ps
                      = 202918100 ps

Pipelined CPU time = 213598 x 1.0497 x 270 ps
                   = 60540480 ps

Speedup = single-cycle CPU time / pipelined CPU time
        = 202918100 / 60540480
        = 3.35
```

Discussion question: Why is it incorrect to compare only CPI when one processor is single-cycle and the other is pipelined?

## Part A: In-Order Scalar Pipeline

Create `config_a.cfg`:

```bash
cp labs/default.cfg labs/config_a.cfg
```

Edit `labs/config_a.cfg` and set:

```text
-fetch:ifqsize 1
-decode:width 1
-issue:width 1
-issue:inorder true
-ruu:size 8
-lsq:size 8
-res:ialu 1
-res:imult 1
-res:memport 1
-res:fpalu 1
-res:fpmult 1
```

Run the simulation:

```bash
cd labs
../simplesim-3.0/sim-outorder -config config_a.cfg -ptrace config_a.trc 0:1024 -redir:sim sim_configa.out ./test-math
```

View the IPC:

```bash
grep sim_IPC sim_configa.out
```

View the pipeline trace:

```bash
../simplesim-3.0/pipeview.pl config_a.trc | less
```

Record:

| Configuration | Issue mode | Decode width | Issue width | Functional units | IPC |
| --- | --- | ---: | ---: | --- | ---: |
| A | in-order | 1 | 1 | one of each | |

### Questions for Part A

1. Describe the processor represented by `config_a.cfg`.
2. What is the measured IPC?
3. Find one RAW dependency in the pipeline trace. Does the trace suggest that forwarding is implemented? Explain using cycle evidence.
4. Why does an in-order pipeline stall when an older instruction is not ready?

## Part B: Out-of-Order Scalar Pipeline

Create `config_b.cfg`:

```bash
cp config_a.cfg config_b.cfg
```

Edit `config_b.cfg` and change only:

```text
-issue:inorder false
```

Run:

```bash
../simplesim-3.0/sim-outorder -config config_b.cfg -redir:sim sim_configb.out ./test-math
```

Record:

| Configuration | Issue mode | Decode width | Issue width | Functional units | IPC |
| --- | --- | ---: | ---: | --- | ---: |
| A | in-order | 1 | 1 | one of each | |
| B | out-of-order | 1 | 1 | one of each | |

### Questions for Part B

1. What is the key difference between configurations A and B?
2. What is the IPC of configuration B?
3. Does out-of-order execution improve performance for `test-math`? Quantify the improvement.
4. In an out-of-order processor, why must the commit stage update architectural state in program order?

## Submission

Submit:

- The completed comparison table.
- `sim_configa.out` and `sim_configb.out`, or the relevant copied statistics.
- One short pipeline-trace example used to discuss forwarding.
- Answers to all questions.

## Discussion Prompt

Out-of-order issue alone may not create a large speedup if the processor is still single issue and has a narrow front end. Explain whether your measured results support this statement.
