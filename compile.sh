#!/bin/bash
#SBATCH -A f202500010hpcvlabuminhoa
#SBATCH -p normal-arm
#SBATCH -t 00:30:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=48
#SBATCH --output=compile_out.o%j
#SBATCH --error=compile_err.e%j

# === Environment setup ===
module purge
module load GCC/13.3.0
module load Score-P/8.0

echo "[INFO] Cleaning previous builds..."
make clean

echo "[INFO] Compiling ZPIC with Score-P (GCC 13.3.0)"
make CC="scorep gcc" CFLAGS="-Ofast -g -std=c99 -pedantic -Wall" LDFLAGS="-lm"

# === Verification ===
if [ -f ./zpic ]; then
    echo "[SUCCESS] Compilation complete — executable 'zpic' created in $(pwd)"
else
    echo "[ERROR] Compilation failed!"
    exit 1
fi

exit 0

