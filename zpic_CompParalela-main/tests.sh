#!/bin/bash

# =========================================================================== #
# Test different configurations - ZPIC Project
# =========================================================================== #
# - University - University of Minho
# - Course - Parallel Computing (MCA)
# - Authors - Diogo Silva & Tomás Pereira
# =========================================================================== #

#SBATCH -A f202500010hpcvlabuminhoa
#SBATCH -p normal-arm
#SBATCH -t 00:10:00    # 10 minutes max run
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=tests/slurm_logs/compile_out.o%j
#SBATCH --error=tests/slurm_logs/compile_err.e%j
#SBATCH --exclusive
#SBATCH --acctg-freq=energy=10


# --------- LOAD MODULES -----------------
echo "[STARTING] Loading modules"
modules=(
    "GCC/13"
    "Score-P/8.4-gompi-2024a"
)

ml purge

for module in "${modules[@]}"; do
    echo "[LOAD_MODULE] $module"
    ml "$module"
done

# --------- PARSE ARGUMENTS -------------
TEST_NAME=$1
CONFIG=$2
CORES=$3
PARALLEL=$4

if [ -z "$TEST_NAME" ]; then
    echo "Usage: sbatch run_tests.sh <test_name> <?config> <?cores>"
    exit 1
fi

if [ -z "$CONFIG" ]; then
    CONFIG="NO_OPT"
fi

if [ -z "$CORES" ]; then
    CORES=1
fi

if [ "$CORES" -gt 48 ] || [ "$CORES" -lt 1 ]; then
    echo "Warning: CORES ($CORES) out of range [1-48]. Setting CORES=1."
    CORES=1
fi

if [ "$CORES" -gt 1 ]; then
    PARALLEL="Y"
else
    PARALLEL="N"
fi



# --------- RUN TESTS --------------------

mkdir -p tests/slurm_logs

case $TEST_NAME in
    gcc)
        echo "Running test with GCC"
        make clean
        make CONFIG="$CONFIG" OMP_NUM_THREADS="$CORES" PARALLEL="$PARALLEL"
        srun -c $CORES ./zpic
        ;;

    scorep)
        echo "Running Score-P test with CONFIG=$CONFIG and CORES=$CORES"
	    make clean
	    make CC="scorep gcc" CONFIG="$CONFIG" DEBUG="Y" OMP_NUM_THREADS="$CORES" PARALLEL="$PARALLEL"
	    mkdir -p tests/scorep
	    SCOREP_DIR="tests/scorep/score_${CONFIG}_${CORES}_threads"a
	    export SCOREP_EXPERIMENT_DIRECTORY="$SCOREP_DIR"
	    srun -c "$CORES" ./zpic &> "${SCOREP_DIR}.log"
        ;;
    perf_stat)
        echo "Running perf test with CONFIG=$CONFIG and CORES=$CORES"
        make clean
        make CONFIG="$CONFIG" OMP_NUM_THREADS="$CORES" OMP_PARALLEL="$PARALLEL"
        mkdir -p tests/perf
        PERF_DIR="tests/perf/perf_stat_${CONFIG}_${CORES}_threads.txt"
        srun -c $CORES perf stat ./zpic &> "$PERF_DIR"
        echo "Perf stats saved to $PERF_OUT"
        ;;
    perf_record)
        echo "Running perf record with CONFIG=$CONFIG and CORES=$CORES"
        make clean
        make CONFIG="$CONFIG" OMP_NUM_THREADS="$CORES" DEBUG="Y" OMP_PARALLEL="$PARALLEL"
        mkdir -p tests/perf
        PERF_DIR="tests/perf/perf_record_${CONFIG}_${CORES}_threads.data"
        srun -c "$CORES" perf record -g --call-graph dwarf -o "$PERF_DIR" -- ./zpic
        ;;
    *)
        echo "Unknown test name: $TEST_NAME"
        exit 1
        ;;
esac

exit 0
