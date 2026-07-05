# Home Assignment: Processor Bottleneck Analysis With SimpleScalar

## Purpose

This assignment extends Lab 2 by changing one architectural feature at a time. Students will identify whether performance is limited by issue policy, pipeline width, functional units, or instruction window size.

## Starting Point

Complete Lab 2 before beginning this assignment. Use the same `SimpleScalar/labs/` directory and the same `test-math` PISA binary.

If needed, rebuild for PISA:

```bash
cd SimpleScalar/simplesim-3.0
make clean
make config-pisa
make
cd ../labs
```

## Part A: More Functional Units in an In-Order Processor

Create `config_c.cfg` from the default configuration:

```bash
cp ../simplesim-3.0/config/default.cfg config_c.cfg
```

Set:

```text
-fetch:ifqsize 1
-decode:width 1
-issue:width 1
-issue:inorder true
-ruu:size 8
-lsq:size 8
-res:ialu 4
-res:imult 4
-res:memport 4
-res:fpalu 4
-res:fpmult 4
```

Run:

```bash
../simplesim-3.0/sim-outorder -config config_c.cfg -redir:sim sim_configc.out ./test-math
```

Questions:

1. What is the IPC of configuration C?
2. Compare C with configuration A from Lab 2. Does adding functional units help an in-order single-issue pipeline?
3. Which part of the design is the bottleneck?

## Part B: More Functional Units With Out-of-Order Issue

Create `config_d.cfg`:

```bash
cp config_c.cfg config_d.cfg
```

Change:

```text
-issue:inorder false
```

Run:

```bash
../simplesim-3.0/sim-outorder -config config_d.cfg -redir:sim sim_configd.out ./test-math
```

Questions:

1. What is the IPC of configuration D?
2. Compare D with C. Does out-of-order execution help when resources are plentiful but the pipeline is narrow?
3. Create two extra temporary configurations from D:
   - one with only `-decode:width 4`
   - one with only `-issue:width 4`
4. Do either of those single changes improve IPC? Explain why or why not.

## Part C: Wide Pipeline With Few Functional Units

Create `config_e.cfg`:

```bash
cp ../simplesim-3.0/config/default.cfg config_e.cfg
```

Set:

```text
-fetch:ifqsize 4
-decode:width 4
-issue:width 4
-issue:inorder false
-ruu:size 8
-lsq:size 8
-res:ialu 1
-res:imult 1
-res:memport 1
-res:fpalu 1
-res:fpmult 1
```

Run:

```bash
../simplesim-3.0/sim-outorder -config config_e.cfg -redir:sim sim_confige.out ./test-math
```

Questions:

1. What is the IPC of configuration E?
2. Compare E with configuration B from Lab 2.
3. Does widening the pipeline front end help if execution resources remain limited?

## Part D: Wide Pipeline With Many Functional Units

Create `config_f.cfg`:

```bash
cp config_e.cfg config_f.cfg
```

Change all functional unit counts to 4:

```text
-res:ialu 4
-res:imult 4
-res:memport 4
-res:fpalu 4
-res:fpmult 4
```

Run:

```bash
../simplesim-3.0/sim-outorder -config config_f.cfg -redir:sim sim_configf.out ./test-math
```

Questions:

1. What is the IPC of configuration F?
2. Why does this configuration perform better than C, D, or E?
3. What does this result teach about balanced processor design?

## Part E: Larger Instruction Window

Create `config_g.cfg`:

```bash
cp config_f.cfg config_g.cfg
```

Change:

```text
-ruu:size 16
```

Run:

```bash
../simplesim-3.0/sim-outorder -config config_g.cfg -redir:sim sim_configg.out ./test-math
```

Questions:

1. What is the IPC of configuration G?
2. Compare G with F. Does a larger instruction window improve performance?
3. Why might the gain from increasing RUU size be smaller than the gain from moving to a balanced 4-way superscalar design?

## Required Summary Table

| Config | Issue mode | Fetch queue | Decode width | Issue width | RUU | LSQ | Functional units | IPC | Main bottleneck |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- | ---: | --- |
| A | in-order | 1 | 1 | 1 | 8 | 8 | one each | | |
| B | out-of-order | 1 | 1 | 1 | 8 | 8 | one each | | |
| C | in-order | 1 | 1 | 1 | 8 | 8 | four each | | |
| D | out-of-order | 1 | 1 | 1 | 8 | 8 | four each | | |
| E | out-of-order | 4 | 4 | 4 | 8 | 8 | one each | | |
| F | out-of-order | 4 | 4 | 4 | 8 | 8 | four each | | |
| G | out-of-order | 4 | 4 | 4 | 16 | 8 | four each | | |

## Submission

Submit:

- The completed summary table.
- Answers to all questions.
- A bar chart showing IPC for configurations A through G.
- A one-page conclusion explaining the main bottleneck in each design.
- Simulator output files or copied `sim_IPC` lines for every configuration.
