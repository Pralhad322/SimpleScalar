# SimpleScalar Course Lab Package

This repository is prepared for computer architecture labs using SimpleScalar/PISA.

## Quick Start

From the repository root:

```bash
make
```

This builds the SimpleScalar simulators, including the educational `sim-singlecycle` simulator used in the processor-design lab.

To install the local PISA little-endian cross compiler for compiling student C programs:

```bash
bash scripts/install_pisa_cross_compiler.sh --install-deps
```

If the required Ubuntu/Debian build packages are already installed:

```bash
bash scripts/install_pisa_cross_compiler.sh
```

## Manuals

Start with:

```text
SimpleScalar/manuals/README.md
```

The custom C compilation lab is:

```text
SimpleScalar/manuals/06_compiling_custom_c_for_pisa.md
```

## Important Notes

- The repository is configured for PISA little-endian experiments.
- Do not use a generic `mips-linux-gnu-gcc` for SimpleScalar PISA programs.
- The local cross compiler is installed under `toolchain/`, which is intentionally not committed.
- Generated simulator outputs under `labs/*.out`, `labs/*.trc`, and `labs/*.pisa` are intentionally ignored.
