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
#SBATCH -t 00:03:00    # 3 minutes max run
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=compile_out.o%j
#SBATCH --error=compile_err.e%j
#SBATCH --exclusive

# --------- LOAD MODULES -----------------
echo "[STARTING] Loading modules"
modules=(
    "GCC/13.3.0"
    "Score-P/8.0"
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

if [ -z "$TEST_NAME" ]; then
    echo "Usage: sbatch run_tests.sh <test_name> <?config> <?cores>"
    exit 1
fi

if [ -z "$CONFIG" ]; then
    CONFIG="OPT_FULL"
fi

if [ -z "$CORES" ]; then
    CORES=1
fi

if [ "$CORES" -gt 48 ] || [ "$CORES" -lt 1 ]; then
    echo "Warning: CORES ($CORES) out of range [1-48]. Setting CORES=1."
    CORES=1
fi

# --------- RUN TESTS --------------------
case $TEST_NAME in
    gcc)
        echo "Running test with GCC"
        make clean
        make CONFIG="$CONFIG"
        srun -c $CORES ./zpic
        ;;

    scorep-1)
        echo "Running Score-P test with CONFIG=$CONFIG and CORES=$CORES"
        make clean
        make CC="scorep gcc" CONFIG="$CONFIG"
        srun -c $CORES ./zpic
        ;;

    perf)
        echo "Running perf test with CONFIG=$CONFIG and CORES=$CORES"
        make clean
        make CONFIG="$CONFIG"
        mkdir -p tests/perf
        PERF_DIR="tests/perf/perf_${CONFIG}_${CORES}_threads.txt"
        srun -c $CORES perf -r 3 stat ./zpic &> "$PERF_DIR"
        echo "Perf stats saved to $PERF_OUT"
        ;;
    *)
        echo "Unknown test name: $TEST_NAME"
        exit 1
        ;;
esac

exit 0
