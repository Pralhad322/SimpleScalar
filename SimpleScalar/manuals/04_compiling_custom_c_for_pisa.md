# Compiling Custom C Programs for SimpleScalar PISA

## Purpose

This note shows how to compile small C programs into SimpleScalar PISA little-endian binaries. Use this when students want to run their own C examples with `sim-safe`, `sim-singlecycle`, or `sim-outorder`.

## Toolchain Location

The local compiler is installed inside the workspace:

```bash
toolchain/sslittle-na-sstrix/bin/gcc
```

This is a SimpleScalar/PISA little-endian compiler. Do not replace it with a generic `mips-linux-gnu-gcc`, because generic MIPS Linux compilers usually produce ELF/Linux binaries instead of SimpleScalar ECOFF/SSTrix binaries.

## Install on Each Lab Machine

Copy or clone the same `simplesim-3.0` workspace onto each student machine. Then run from that workspace:

```bash
cd /path/to/simplesim-3.0
bash scripts/install_pisa_cross_compiler.sh --install-deps
```

The `--install-deps` option installs required Ubuntu/Debian packages using `apt-get`, so it may ask for the sudo password. If the machine already has the required build tools, use:

```bash
cd /path/to/simplesim-3.0
bash scripts/install_pisa_cross_compiler.sh
```

To rebuild from clean extracted sources and a clean local install prefix:

```bash
bash scripts/install_pisa_cross_compiler.sh --force
```

The script installs only inside:

```text
toolchain/sslittle-na-sstrix
```

It does not install a system-wide compiler and does not use `mips-linux-gnu-gcc`.

## Compile a Test Program

From the `simplesim-3.0` workspace, compile:

```bash
toolchain/sslittle-na-sstrix/bin/gcc -O2 -static -o labs/hello.pisa labs/hello.c
```

Confirm the binary format:

```bash
file labs/hello.pisa
```

Expected:

```text
labs/hello.pisa: MIPSEL ECOFF executable
```

`MIPSEL` means MIPS/PISA little-endian. `ECOFF` is the executable format expected by this SimpleScalar PISA setup.

## Run the Program

Functional execution:

```bash
./sim-safe labs/hello.pisa
```

Educational single-cycle model:

```bash
./sim-singlecycle -redir:sim labs/hello_singlecycle.out labs/hello.pisa
grep -E "sim_num_insn|sim_cycle|sim_IPC|sim_CPI" labs/hello_singlecycle.out
```

Expected single-cycle relationship:

```text
sim_cycle = sim_num_insn
sim_IPC = 1.0000
sim_CPI = 1.0000
```

Pipelined/out-of-order timing model:

```bash
./sim-outorder -redir:sim labs/hello_pipeline.out labs/hello.pisa
grep -E "sim_num_insn|sim_cycle|sim_IPC|sim_CPI" labs/hello_pipeline.out
```

Use `sim_cycle`, `sim_IPC`, and `sim_CPI` from `sim-outorder` when discussing the simulated pipelined processor.

## Important Teaching Note

SimpleScalar reports simulated cycles, instruction count, IPC, and CPI. It does not measure physical clock period in ps or ns. For single-cycle versus pipelined CPU-time comparison, use:

```text
CPU time = instruction count x CPI x assumed clock cycle time
```

The clock cycle time must come from an assumed datapath delay model supplied by the instructor.
