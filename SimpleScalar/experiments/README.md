# SimpleScalar Computer Architecture Lab Experiments

This folder contains the student experiment handouts for the SimpleScalar computer architecture lab sequence. Each experiment is provided as a PDF for printing, a Markdown file for copying commands, and a LaTeX source file for editing.
Repository layout after cloning:
```bash
SimpleScalar/
  benchmarks/
  config/
  labs/
  scripts/
  SimpleScalar/
    experiments/
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

- Lab 0: setup, build targets, and simulator overview. Files: `00_setup_and_orientation.pdf`, `00_setup_and_orientation.md`. Simulator: all.
- Lab 1: instruction set profiling and Alpha vs PISA comparison. Files: `01_isa_profiling_lab.pdf`, `01_isa_profiling_lab.md`. Simulator: `sim-profile`.
- Lab 2: in-order and out-of-order pipelined processors. Files: `02_processor_design_lab.pdf`, `02_processor_design_lab.md`. Simulator: `sim-outorder`.
- Lab 2 extension: superscalar bottleneck and design-space analysis.
Files: `03_processor_design_home_assignment.pdf`
`03_processor_design_home_assignment.md`
Simulator: `sim-outorder`.
- Lab 3: branch predictor accuracy and CPI impact. Files: `04_branch_prediction_lab.pdf`, `04_branch_prediction_lab.md`. Simulators: `sim-bpred`, `sim-outorder`.
- Lab 4: educational single-cycle processor model. Files: `05_singlecycle_processor_lab.pdf`, `05_singlecycle_processor_lab.md`. Simulator: `sim-singlecycle`.
- Lab 5: compile custom C programs for PISA. Files: `06_compiling_custom_c_for_pisa.pdf`, `06_compiling_custom_c_for_pisa.md`. Simulators: `sim-safe`, `sim-profile`.

## Notes

- Lab 1 uses Alpha and PISA builds. Rebuild with `make clean` before switching ISA targets.
- Labs 2, 4, and 5 use PISA.
- Lab 3 uses Alpha benchmarks for branch prediction, matching the original UMass SimpleScalar reference lab.
- The local PISA cross compiler is installed under `toolchain/` by `scripts/install_pisa_cross_compiler.sh`; it is not committed to the repository.
