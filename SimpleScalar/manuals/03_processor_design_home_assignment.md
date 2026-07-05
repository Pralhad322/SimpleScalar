# Lab 2 Extension: Pipelining and Superscalar Design Space

## Introduction

This lab extends the previous processor-design lab. Students change one architectural feature at a time and identify whether performance is limited by issue policy, pipeline width, functional units, or instruction window size.

Run setup commands from the cloned repository root:

```bash
cd /path/to/SimpleScalar
make clean
make config-pisa
make
mkdir -p labs
cp tests-pisa/bin.little/test-math labs/
```

## Part 1: Increasing Functional Units in an In-Order Processor

Create `config_c.cfg`:

```bash
cp config/default.cfg labs/config_c.cfg
```

In `labs/config_c.cfg`, set:

```text
-decode:width 1
-fetch:ifqsize 1
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
cd labs
../sim-outorder -config config_c.cfg -redir:sim sim_configc.out ./test-math
```

Questions:

1. What is the IPC of `test-math` using this configuration?
2. Compare this configuration with configuration A from Lab 2. Does adding resources increase performance in an in-order pipeline?

## Part 2: Increasing Functional Units With Out-of-Order Issue

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
../sim-outorder -config config_d.cfg -redir:sim sim_configd.out ./test-math
```

Questions:

1. What is the IPC using this configuration?
2. Compare this configuration with Part 1. Does out-of-order execution help when resources are plentiful but pipeline width is narrow?
3. The system contains four functional units. Find the bottleneck by running multiple simulations based on `config_d.cfg`, changing only one of these parameters to 4 at a time:

```text
-decode:width 4
-issue:width 4
```

4. Does performance increase? What is the main bottleneck in configuration D?

## Part 3: Widening the Pipeline

Create `config_e.cfg`:

```bash
cd /path/to/SimpleScalar
cp config/default.cfg labs/config_e.cfg
cd labs
```

In `config_e.cfg`, set:

```text
-fetch:ifqsize 4
-decode:width 4
-lsq:size 8
-ruu:size 8
-issue:width 4
-issue:inorder false
-res:ialu 1
-res:imult 1
-res:memport 1
-res:fpalu 1
-res:fpmult 1
```

Run:

```bash
../sim-outorder -config config_e.cfg -redir:sim sim_confige.out ./test-math
```

Questions:

1. What is the IPC for this configuration?
2. Compare this configuration with configuration B from Lab 2. What is the effect of widening the pipeline front end?

## Part 4: Wide Pipeline and Many Resources

Create `config_f.cfg`:

```bash
cp config_e.cfg config_f.cfg
```

Set all resource types to 4:

```text
-res:ialu 4
-res:imult 4
-res:memport 4
-res:fpalu 4
-res:fpmult 4
```

Run:

```bash
../sim-outorder -config config_f.cfg -redir:sim sim_configf.out ./test-math
```

Question:

1. What is the IPC for this configuration?

## Part 5: Increasing the Instruction Window

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
../sim-outorder -config config_g.cfg -redir:sim sim_configg.out ./test-math
```

Question:

1. What is the IPC for this configuration?

## Summary Table

| Config | Issue mode | Fetch queue | Decode width | Issue width | RUU | LSQ | Functional units | IPC |
| --- | --- | ---: | ---: | ---: | ---: | ---: | --- | ---: |
| A | in-order | 1 | 1 | 1 | 8 | 8 | one each | |
| B | out-of-order | 1 | 1 | 1 | 8 | 8 | one each | |
| C | in-order | 1 | 1 | 1 | 8 | 8 | four each | |
| D | out-of-order | 1 | 1 | 1 | 8 | 8 | four each | |
| E | out-of-order | 4 | 4 | 4 | 8 | 8 | one each | |
| F | out-of-order | 4 | 4 | 4 | 8 | 8 | four each | |
| G | out-of-order | 4 | 4 | 4 | 16 | 8 | four each | |
