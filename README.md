# ZPIC Parallel WA1 — A64FX Optimization Study

> Optimization of the ZPIC Particle-In-Cell simulation on the Fujitsu A64FX ARM nodes of the Deucalion supercomputer.

![Language](https://img.shields.io/badge/language-C-blue)
![Parallelism](https://img.shields.io/badge/parallelism-OpenMP%20%7C%20SVE%20%7C%20Score--P-orange)
![Platform](https://img.shields.io/badge/platform-Deucalion%20A64FX-green)


## Overview

This repository contains the first work assignment for the Parallel Computing course, focused on improving the performance of **ZPIC**, an educational Particle-In-Cell (PIC) simulation code, on the **Fujitsu A64FX** ARM architecture available in the **Deucalion** supercomputer.

The work investigates how ZPIC behaves under:

- single-core optimization,
- SVE-oriented data layout transformations,
- OpenMP multi-threading,
- hotspot profiling,
- memory-bandwidth analysis,
- strong scalability testing on A64FX.

The main conclusion is that ZPIC sits in a difficult performance region between **compute-bound** and **memory-bound** execution. Although SVE vectorization improves single-core performance significantly, multi-core scaling is ultimately constrained by HBM2 bandwidth saturation, OpenMP overhead, and irregular particle-memory access patterns.

## Academic Context

- **Course:** Parallel Computing  
- **Institution:** University of Minho  
- **Target system:** Deucalion supercomputer  
- **Target architecture:** Fujitsu A64FX ARM node  
- **Authors:**  
  - Diogo Coelho da Silva  
  - Tomás Alexandre Torres Pereira  

## Repository Structure

```text
.
├── input/                         # ZPIC input configurations
├── results/                       # Experimental output and profiling results
├── scorep-*/                      # Score-P profiling experiment directory
├── current.c / current.h          # Current deposition and filtering routines
├── emf.c / emf.h                  # Electromagnetic field update routines
├── particles.c / particles.h      # Particle structures and pusher implementation
├── simulation.c / simulation.h    # Main simulation orchestration
├── random.c / random.h            # Random number utilities
├── timer.c / timer.h              # Timing utilities
├── zdf.c / zdf.h                  # ZPIC diagnostic file support
├── main.c                         # Program entry point
├── Makefile                       # Build configuration
├── compile.sh                     # SLURM compilation script for Deucalion
├── run.sh                         # SLURM execution/profiling script
└── ZPIC_optimization.pdf          # Final technical report
```

## Technical Focus

The project targets the main performance bottlenecks of ZPIC on A64FX:

| Area | Optimization Strategy |
|---|---|
| Data layout | Replaced Array-of-Structures patterns with Structure-of-Arrays buffers |
| Vectorization | Enabled SVE-friendly memory access using Clang and contiguous field arrays |
| Particle pusher | Parallelized `spec_advance` with OpenMP |
| Current deposition | Removed naïve atomic updates through block-partitioned deposition |
| Current smoothing | Used temporary buffers to avoid serialization in `kernel_x` |
| Profiling | Used `perf`, Firefox Profiler, and Score-P |
| Scalability | Measured strong scaling from 1 to 48 threads |

## Architecture: Fujitsu A64FX

The experiments were performed on a Deucalion ARM node equipped with a Fujitsu A64FX processor. This architecture is especially relevant for this work because it provides:

- 48 compute cores,
- 4 Core Memory Groups (CMGs),
- SVE 512-bit vector units,
- high-bandwidth HBM2 memory,
- strong dependence on memory locality and vectorization efficiency.

The report highlights that scaling beyond one CMG introduces additional overhead and memory contention, which explains why the best performance is achieved around **8–12 threads**, not at the maximum 48-thread configuration.

## Main Optimizations

### 1. SVE-Oriented Data Layout

The original ZPIC code used data structures such as `Float3` and `Particle` in an **Array of Structures (AoS)** layout. This layout makes vectorization harder because each field is interleaved in memory.

To improve this, the code was reorganized into a **Structure of Arrays (SoA)** representation through new buffer abstractions such as:

- `Float3Buffer`
- `ParticleBuffer`

This exposes contiguous vectors of each field and allows the compiler to generate more effective SVE instructions.

### 2. Compiler Strategy

The work explored compiler behavior on A64FX and found that **Clang** was more effective than GCC for enforcing SVE vectorization patterns.

The optimized version increased the proportion of retired SVE instructions from approximately **0%** to **23%**.

### 3. OpenMP Parallelization

Thread-level parallelism was introduced in the main hotspot regions:

- `spec_advance`
- `kernel_x`
- `emf_advance`

The most important routine was `spec_advance`, since it dominates execution time and contains irregular particle-field interpolation and current deposition.

### 4. Avoiding Atomic Contention

A naïve OpenMP implementation of current deposition would require frequent `#pragma omp atomic` operations. This would serialize the update path and destroy scalability.

Instead, this project used a **block-partitioned deposition scheme**, where the simulation domain is divided into independent regions and each thread deposits currents inside its own assigned block.

### 5. Current Smoothing Optimization

The `kernel_x` current smoothing stage was also optimized by using temporary buffers. This avoids direct write conflicts and reduces serialization during the smoothing phase.

## Performance Results

### Single-Core SVE Optimization

| Version | Execution Time | Improvement |
|---|---:|---:|
| Baseline | ~81.2 s | 1.0× |
| SVE-optimized | ~38.7 s | ~2.1× |

The SVE-oriented data layout transformation produced a major single-core improvement by exposing more vectorizable memory access patterns.

### Multi-Thread Strong Scalability

| Threads | Simulation Time | Speedup |
|---:|---:|---:|
| 1 | 38.739 s | 1.00× |
| 2 | 22.497 s | 1.72× |
| 4 | 14.099 s | 2.75× |
| 8 | 10.280 s | 3.77× |
| 10 | 9.453 s | 4.10× |
| 12 | 8.993 s | **4.31×** |
| 16 | 10.080 s | 3.84× |
| 24 | 10.132 s | 3.82× |
| 32 | 11.772 s | 3.29× |
| 48 | 14.550 s | 2.66× |

The best configuration was obtained at **12 threads**, corresponding to one A64FX CMG. Beyond this point, performance degrades due to memory bandwidth saturation, OpenMP overhead, and cross-CMG effects.

## Key Findings

- ZPIC benefits strongly from SVE-aware data restructuring.
- AoS layouts significantly restrict vectorization on A64FX.
- SoA layouts improve compiler vectorization and memory access regularity.
- OpenMP improves performance up to one CMG.
- The optimal A64FX configuration is around **8–12 threads**.
- Using all 48 cores is not optimal for this workload.
- The application becomes increasingly memory-bandwidth limited as thread count grows.
- Repeated creation of OpenMP teams contributes to overhead beyond 12 threads.
- Further improvements require deeper algorithmic restructuring.

## Build Instructions

The repository includes a `Makefile` and Deucalion SLURM scripts.

### Local Build

```bash
make clean
make
```

The default target builds the executable:

```bash
./zpic
```

### Deucalion Compilation

The provided SLURM compilation script uses GCC 13.3.0 and Score-P:

```bash
sbatch compile.sh
```

The script performs:

```bash
module purge
module load GCC/13.3.0
module load Score-P/8.0

make clean
make CC="scorep gcc" CFLAGS="-Ofast -g -std=c99 -pedantic -Wall" LDFLAGS="-lm"
```

## Run Instructions

To run the simulation on Deucalion:

```bash
sbatch run.sh
```

The execution script:

- targets the `normal-arm` partition,
- requests one A64FX node,
- allocates 48 CPUs per task,
- runs the executable multiple times,
- stores results under `results/`,
- collects `perf` counters such as cycles, instructions, and task-clock.

For manual execution:

```bash
export OMP_NUM_THREADS=12
./zpic
```

Recommended configurations:

```bash
export OMP_NUM_THREADS=8
./zpic
```

or:

```bash
export OMP_NUM_THREADS=12
./zpic
```

## Profiling

The project used multiple profiling tools:

### perf

```bash
perf stat -e cycles,instructions,task-clock ./zpic
```

### Score-P

The build script compiles the code with Score-P instrumentation:

```bash
make CC="scorep gcc"
```

### Firefox Profiler

Firefox Profiler was used to identify hotspot regions and guide the optimization strategy.

## Interpretation of Results

The strongest performance gain came from **single-core vectorization**, not from simply increasing thread count. This is typical for A64FX when a workload is sensitive to:

- memory layout,
- contiguous accesses,
- vector instruction generation,
- cache-line utilization,
- HBM2 bandwidth saturation.

The multi-threading results show that more cores do not automatically imply better performance. Once the workload saturates the available memory bandwidth inside one CMG, additional threads introduce overhead without providing proportional computation throughput.

This makes the project a practical case study in architecture-aware optimization: the best version is not the most parallel version, but the version that balances vectorization, locality, and memory bandwidth.

## Future Work

The report identifies several directions for future improvement:

1. **Persistent OpenMP parallel regions**  
   Create the OpenMP team once at a higher level instead of repeatedly entering and leaving parallel regions inside simulation iterations.

2. **MPI domain decomposition**  
   PIC methods naturally support spatial decomposition. A proper MPI version could distribute the simulation domain across multiple nodes.

3. **Improved particle locality**  
   Particle sorting or binning by cell could improve cache reuse and reduce irregular memory access.

4. **NUMA/CMG-aware placement**  
   Explicit thread and memory placement could reduce cross-CMG traffic.

5. **Deeper vectorization of `spec_advance`**  
   The particle pusher remains the main optimization ceiling due to irregular interpolation and deposition patterns.

6. **Roofline-guided optimization**  
   A detailed roofline model could quantify where each kernel sits relative to A64FX compute and HBM2 limits.

## Authors

**Diogo Coelho da Silva**  
University of Minho  
`pg61444@alunos.uminho.pt`

**Tomás Alexandre Torres Pereira**  
University of Minho  
`pg59810@alunos.uminho.pt`

## Acknowledgements

This work was developed for the Parallel Computing course at the University of Minho and evaluated on the Deucalion supercomputer infrastructure.

## License

This repository is intended for academic and educational use. If reusing this work, please cite the authors and the original ZPIC project.
