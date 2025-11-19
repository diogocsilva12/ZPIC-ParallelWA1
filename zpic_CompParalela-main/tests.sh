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
#SBATCH --cpus-per-task=12
#SBATCH --output=tests/slurm_logs/compile_out.o%j
#SBATCH --error=tests/slurm_logs/compile_err.e%j
#SBATCH --exclusive
#SBATCH --acctg-freq=energy=10

echo "Usage: sbatch tests.sh <TEST_NAME> <?CC> <?CONFIG> <?CORES> <?PARALLEL>"
echo "Example: sbatch tests.sh perf_stat clang OPT_FULL 8 Y"

# --------- LOAD MODULES -----------------
echo "[STARTING] Loading modules"
modules=(
    "GCC/13.3.0"
    "Score-P/8.4-gompi-2024a"
    "LLVM/19"
)

ml purge

for module in "${modules[@]}"; do
    echo "[LOAD_MODULE] $module"
    ml "$module"
done

# --------- PARSE ARGUMENTS -------------
TEST_NAME=$1
CC=$2
CONFIG=$3
CORES=$4
PARALLEL=$5

if [ -z "$TEST_NAME" ]; then
    echo "Usage: Insert a right test (run, scorep, perf_stat, perf_record)"
    exit 1
fi

if [ -z "$CC" ]; then
   CC="clang"
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
    run)
        echo "Running test with GCC"
        make clean
        make CC="$CC" CONFIG="$CONFIG" OMP_NUM_THREADS="$CORES" PARALLEL="$PARALLEL"
        srun -c $CORES ./zpic
        ;;

    scorep)
        echo "Running Score-P test with CONFIG=$CONFIG and CORES=$CORES"
	    make clean
	    make CC="scorep gcc" CONFIG="$CONFIG" OMP_NUM_THREADS="$CORES" PARALLEL="$PARALLEL"
	    mkdir -p tests/scorep
	    SCOREP_DIR="tests/scorep/score_${CONFIG}_${CORES}_threads"a
	    export SCOREP_EXPERIMENT_DIRECTORY="$SCOREP_DIR"
	    srun -c "$CORES" ./zpic &> "${SCOREP_DIR}.log"
        ;;
    perf_stat)
        echo "Running perf test with CONFIG=$CONFIG and CORES=$CORES"
        make clean
        make CC="$CC" CONFIG="$CONFIG" OMP_NUM_THREADS="$CORES" PARALLEL="$PARALLEL"
        mkdir -p tests/perf
        PERF_DIR="tests/perf/perf_stat_${CONFIG}_${CORES}_threads.txt"
        srun -c $CORES perf stat ./zpic &> "$PERF_DIR"
        echo "Perf stats saved to $PERF_OUT"
        ;;
    perf_record)
        echo "Running perf record with CONFIG=$CONFIG and CORES=$CORES"
        make clean
        make CC="$CC" CONFIG="$CONFIG" OMP_NUM_THREADS="$CORES" DEBUG="Y" PARALLEL="$PARALLEL"
        mkdir -p tests/perf
        
        TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
        PERF_DATA="tests/perf/perf_record_${CONFIG}_${CORES}_threads.data"
        PERF_SCRIPT="tests/perf/measurement_${TIMESTAMP}.perf"
        PERF_DIR="tests/perf/perf_stat_${CONFIG}_${CORES}_threads.txt"
        srun -c $CORES perf stat ./zpic &> "$PERF_DIR"

        echo "Recording performance data..."
        srun -c "$CORES" perf record -g --call-graph dwarf -F 99 -o "$PERF_DATA" -- ./zpic
        
        echo "Converting to script format..."
        perf script -i "$PERF_DATA" -F +pid > "$PERF_SCRIPT"
        
        echo "Perf data saved to $PERF_DATA"
        echo "Perf script saved to $PERF_SCRIPT"
        
        # Generate quick summary
        echo ""
        echo "Quick analysis:"
        perf report -i "$PERF_DATA" --stdio --no-children | head -30
        ;;
    *)
        echo "Unknown test name: $TEST_NAME"
        exit 1
        ;;
esac

exit 0
