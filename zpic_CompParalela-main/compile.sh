#!/bin/bash

# =========================================================================== #
# Compile ZPIC Project
# =========================================================================== #
# - University - University of Minho
# - Course - Parallel Computing (MCA)
# - Authors - Diogo Silva & Tomás Pereira
# =========================================================================== #

#SBATCH -A f202500010hpcvlabuminhoa
#SBATCH -p normal-arm
#SBATCH -t 00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --output=tests/slurm_logs/compile_out.o%j
#SBATCH --error=tests/slurm_logs/compile_err.e%j

echo "Usage: sbatch compile.sh <?CC> <?CONFIG> <?PARALLEL>"
echo "Example: sbatch compile.sh clang OPT_FULL Y"

# --------- LOAD MODULES -----------------
echo "[STARTING] Loading modules"
modules=(
    "GCC/13.3.0"
    "LLVM/19"
)

ml purge

for module in "${modules[@]}"; do
    echo "[LOAD_MODULE] $module"
    ml "$module"
done

# --------- PARSE ARGUMENTS -------------
CC=$1
CONFIG=$2
PARALLEL=$3

if [ -z "$CC" ]; then
   CC="clang"
fi

if [ -z "$CONFIG" ]; then
    CONFIG="OPT_FULL"
fi

if [ -z "$PARALLEL" ]; then
    PARALLEL="Y"
fi

echo "[COMPILE] CC=$CC CONFIG=$CONFIG PARALLEL=$PARALLEL"

mkdir -p tests/slurm_logs

make clean
make CC="$CC" CONFIG="$CONFIG" PARALLEL="$PARALLEL"

echo "[DONE] Compilation complete. Executable: zpic"

exit 0
