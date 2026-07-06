# Lab 3: Branch Prediction Using SimpleScalar

## Objective

This lab studies the effect of branch prediction schemes on branch address prediction rate and processor CPI/IPC. The lab uses `sim-bpred` for branch predictor statistics and `sim-outorder` for timing impact.
The structure follows the UMass SimpleScalar branch prediction lab, with paths updated for the current repository layout:
```bash
http://www.ecs.umass.edu/ece/koren/architecture/Simplescalar/branch_prediction.htm
```

Run all commands from the cloned repository root.
```bash
cd /path/to/SimpleScalar
```

## Setup

Configure for Alpha because this lab uses the Alpha benchmarks from Lab 1:
```bash
make clean
make config-alpha
make
mkdir -p labs
```

Get help for `sim-bpred`:
```bash
./sim-bpred -h
```

Important predictor option:
```bash
-bpred {nottaken|taken|bimod|2lev|comb}
```

Useful statistics:
| Statistic pattern | Meaning |
| --- | --- |
| `bpred_taken.bpred_addr_rate` | Branch address prediction rate for taken predictor. |
| `bpred_nottaken.bpred_addr_rate` | Branch address prediction rate for not-taken predictor. |
| `bpred_bimod.bpred_addr_rate` | Branch address prediction rate for bimodal predictor. |
| `*.bpred_dir_rate` | Branch direction prediction rate. |

## Part 1: Branch Address Prediction Rate

Run each benchmark using three prediction schemes: taken, not taken, and bimodal.
### `anagram.alpha`

```bash
./sim-bpred -bpred taken -redir:sim labs/bpred_anagram_taken.out benchmarks/anagram.alpha benchmarks/words < benchmarks/anagram.in
./sim-bpred -bpred nottaken -redir:sim labs/bpred_anagram_nottaken.out benchmarks/anagram.alpha benchmarks/words < benchmarks/anagram.in
./sim-bpred -bpred bimod -redir:sim labs/bpred_anagram_bimod.out benchmarks/anagram.alpha benchmarks/words < benchmarks/anagram.in
```

### `go.alpha`

```bash
./sim-bpred -bpred taken -redir:sim labs/bpred_go_taken.out benchmarks/go.alpha 50 9 benchmarks/2stone9.in
./sim-bpred -bpred nottaken -redir:sim labs/bpred_go_nottaken.out benchmarks/go.alpha 50 9 benchmarks/2stone9.in
./sim-bpred -bpred bimod -redir:sim labs/bpred_go_bimod.out benchmarks/go.alpha 50 9 benchmarks/2stone9.in
```

### `compress95.alpha`

```bash
./sim-bpred -bpred taken -redir:sim labs/bpred_compress_taken.out benchmarks/compress95.alpha < benchmarks/compress95.in
./sim-bpred -bpred nottaken -redir:sim labs/bpred_compress_nottaken.out benchmarks/compress95.alpha < benchmarks/compress95.in
./sim-bpred -bpred bimod -redir:sim labs/bpred_compress_bimod.out benchmarks/compress95.alpha < benchmarks/compress95.in
```

### `cc1.alpha`

```bash
./sim-bpred -bpred taken -redir:sim labs/bpred_cc1_taken.out benchmarks/cc1.alpha -O benchmarks/1stmt.i
./sim-bpred -bpred nottaken -redir:sim labs/bpred_cc1_nottaken.out benchmarks/cc1.alpha -O benchmarks/1stmt.i
./sim-bpred -bpred bimod -redir:sim labs/bpred_cc1_bimod.out benchmarks/cc1.alpha -O benchmarks/1stmt.i
```

Extract prediction rates:
```bash
grep -E "bpred_.*bpred_addr_rate|bpred_.*bpred_dir_rate" labs/bpred_*.out
```

Fill Table 1.
| Benchmark | Taken branch address prediction rate | Not-taken branch address prediction rate | Bimod branch address prediction rate |
| --- | --- | --- | --- |
| `anagram.alpha` |  |  |  |
| `go.alpha` |  |  |  |
| `compress95.alpha` |  |  |  |
| `cc1.alpha` |  |  |  |

Create a histogram for the four benchmarks and draw a conclusion. Does the result agree with your intuition?
## Part 2: CPI Impact Using `sim-outorder`

Use `sim-outorder` to calculate CPI for two benchmarks. The original lab skips the other two because they can take longer to simulate.
Run:
```bash
./sim-outorder -config config/default.cfg -bpred taken -redir:sim labs/ooo_anagram_taken.out benchmarks/anagram.alpha benchmarks/words < benchmarks/anagram.in
./sim-outorder -config config/default.cfg -bpred nottaken -redir:sim labs/ooo_anagram_nottaken.out benchmarks/anagram.alpha benchmarks/words < benchmarks/anagram.in
./sim-outorder -config config/default.cfg -bpred bimod -redir:sim labs/ooo_anagram_bimod.out benchmarks/anagram.alpha benchmarks/words < benchmarks/anagram.in
```

```bash
./sim-outorder -config config/default.cfg -bpred taken -redir:sim labs/ooo_compress_taken.out benchmarks/compress95.alpha < benchmarks/compress95.in
./sim-outorder -config config/default.cfg -bpred nottaken -redir:sim labs/ooo_compress_nottaken.out benchmarks/compress95.alpha < benchmarks/compress95.in
./sim-outorder -config config/default.cfg -bpred bimod -redir:sim labs/ooo_compress_bimod.out benchmarks/compress95.alpha < benchmarks/compress95.in
```

Extract CPI and IPC:
```bash
grep -E "sim_CPI|sim_IPC|sim_num_insn|sim_cycle" labs/ooo_*.out
```

Fill Table 2.
| Benchmark | Taken CPI | Not-taken CPI | Bimod CPI |
| --- | --- | --- | --- |
| `anagram.alpha` |  |  |  |
| `compress95.alpha` |  |  |  |

Create a histogram for the two benchmarks and compare the three schemes.
## Bonus

Write, compile, and run a PISA C program containing a loop that iterates 10 million times. Use the compile-program lab for the compiler setup. Then calculate branch address prediction rate for taken, not-taken, and bimodal predictors.
