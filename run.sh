#!/bin/bash
#SBATCH -A f202500010hpcvlabuminhoa
#SBATCH -p normal-arm
#SBATCH -t 00:35:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --output=run_out.o%j
#SBATCH --error=run_err.e%j

module purge
module load GCC/13.3.0
module load Score-P/8.0

DATE=$(date +"%Y-%m-%d_%H-%M")
EXEC=./zpic
THREADS="1"
RUNS=5

mkdir -p results

for nt in $THREADS; do
    export OMP_NUM_THREADS=$nt
    echo "→ Running with $nt thread(s)"

    for run in $(seq 1 $RUNS); do
        RUN_DIR="results/${DATE}_${nt}t_run${run}"
        mkdir -p "$RUN_DIR"

        SCOREP_EXPERIMENT_DIRECTORY="${RUN_DIR}/scorep" \
            perf stat -r 1 -e cycles,instructions,task-clock \
            $EXEC > "${RUN_DIR}/output.log" 2> "${RUN_DIR}/perf.log"
    done
done

