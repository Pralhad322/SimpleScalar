# SimpleScalar Computer Architecture Lab Manuals

This folder contains editable student manuals for the SimpleScalar computer architecture lab sequence. The commands are written for the current GitHub repository layout, where the cloned repository root is the simulator working directory.

Repository layout after cloning:

```text
SimpleScalar/
  benchmarks/
  config/
  labs/
  scripts/
  SimpleScalar/
    manuals/
  tests-alpha/
  tests-pisa/
  sim-fast.c
  sim-safe.c
  sim-profile.c
  sim-bpred.c
  sim-outorder.c
  sim-singlecycle.c
  Makefile
```

There is no nested `simplesim-3.0/` directory in this repository. Unless a lab explicitly says to enter `labs/`, run commands from the cloned repository root:

```bash
cd /path/to/SimpleScalar
```

## Suggested Lab Sequence

| Lab | Manual | Main topic | Simulator |
| --- | --- | --- | --- |
| 0 | `00_setup_and_orientation.md` | Setup, build targets, simulator overview | all |
| 1 | `01_isa_profiling_lab.md` | Instruction set profiling and Alpha vs PISA comparison | `sim-profile` |
| 2 | `02_processor_design_lab.md` | In-order and out-of-order pipelined processors | `sim-outorder` |
| 2 extension | `03_processor_design_home_assignment.md` | Superscalar bottleneck and design-space analysis | `sim-outorder` |
| 3 | `04_branch_prediction_lab.md` | Branch predictor accuracy and CPI impact | `sim-bpred`, `sim-outorder` |
| 4 | `05_singlecycle_processor_lab.md` | Educational single-cycle processor model | `sim-singlecycle` |
| 5 | `06_compiling_custom_c_for_pisa.md` | Compile custom C programs for PISA | `sim-safe`, `sim-profile` |

## Notes

- Lab 1 uses Alpha and PISA builds. Rebuild with `make clean` before switching ISA targets.
- Labs 2, 4, and 5 use PISA.
- Lab 3 uses Alpha benchmarks for branch prediction, matching the original UMass SimpleScalar reference lab.
- The local PISA cross compiler is installed under `toolchain/` by `scripts/install_pisa_cross_compiler.sh`; it is not committed to the repository.
