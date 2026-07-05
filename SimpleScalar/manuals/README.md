# SimpleScalar Computer Architecture Lab Manuals

This folder contains editable manuals for a computer architecture lab sequence using SimpleScalar. The manuals are written for two audiences:

- Students, who need clear setup steps, experiment procedures, tables, and report questions.
- Instructors, who need preparation notes, expected observations, grading guidance, and troubleshooting help.

The material consolidates the existing PDF manuals in `SimpleScalar/` and follows the experiment style used in the SimpleScalar teaching reference from the UMass architecture course site:

http://www.ecs.umass.edu/ece/koren/architecture/Simplescalar/

## Suggested Lab Sequence

| Week | Manual | Main topic | Simulator |
| --- | --- | --- | --- |
| 1 | `00_setup_and_orientation.md` | Installation, build targets, simulator overview | all |
| 2 | `01_isa_profiling_lab.md` | Instruction set profiling and Alpha vs PISA comparison | `sim-profile` |
| 3 | `02_processor_design_lab.md` | In-order, out-of-order, pipelining, superscalar design | `sim-outorder` |
| 4 | `03_processor_design_home_assignment.md` | Bottleneck analysis and design-space exploration | `sim-outorder` |
| Optional | `04_compiling_custom_c_for_pisa.md` | Compile custom C examples for PISA little-endian | all PISA simulators |

## Files

- `00_setup_and_orientation.md`: common setup guide for all labs.
- `01_isa_profiling_lab.md`: student manual for instruction-set experiments.
- `02_processor_design_lab.md`: student manual for processor design and pipeline experiments.
- `03_processor_design_home_assignment.md`: extended processor design assignment.
- `04_compiling_custom_c_for_pisa.md`: local PISA little-endian cross-compiler usage.
- `instructor_guide.md`: instructor preparation, expected results, discussion points, and grading rubric.
- `student_report_template.md`: reusable report format for submissions.

## Recommended Student Deliverables

Each student or group should submit:

1. Completed result tables.
2. Short answers to analysis questions.
3. A graph or histogram when requested.
4. Simulator output files used to support the answers.
5. A short conclusion explaining the architectural lesson learned.

## Instructor Notes

The manuals assume the lab package has this layout after extracting `SimpleScalar.zip`:

```text
SimpleScalar/
  benchmarks/
  simplesim-3.0/
```

The commands in the student manuals should be run from either:

- `SimpleScalar/simplesim-3.0/` for build and ISA profiling experiments.
- `SimpleScalar/` or `SimpleScalar/labs/` for processor-design experiments, as stated in each command block.

If your local package is installed at a different path, ask students to use the same relative folder structure and avoid hard-coding instructor-specific home directories.
