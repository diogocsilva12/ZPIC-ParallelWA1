# =========================================================================== #
#  Makefile - ZPIC Project
# =========================================================================== #
# - University - University of Minho
# - Course - Parallel Computing (MCA)
# - Authors - Diogo Silva & Tomás Pereira
# ============================================================================= #

SHELL := /bin/bash

# Automatically load LLVM/19 (clang) before any compile command
MODULES := module purge && module load LLVM/19
export MODULES

OMP_NUM_THREADS?=12
OMP_PLACES?=cores
OMP_PROC_BIND?=close

MAKEFLAGS += --no-print-directory

# Force CLANG
CC = clang

CFLAGS_DEFAULT = -std=c99 -pedantic -Wall
CFLAGS_OPT_2_GCC = -O2 -march=native
CFLAGS_OPT_2_CLANG = -O2 -mcpu=a64fx
CFLAGS_OPT_3_GCC = -O3 -march=native
CFLAGS_OPT_3_CLANG = -O3 -mcpu=a64fx
CFLAGS_OPT_FULL_GCC = -Ofast -march=native
CFLAGS_OPT_FULL_CLANG= -O3 -ffast-math -mcpu=a64fx

CFLAGS_PARALLEL = -fopenmp
LDFLAGS = -lm

CONFIG ?= OPT_FULL
PARALLEL ?= Y
DEBUG ?= N

# Choose CFLAGS based on CONFIG
ifeq ($(CONFIG), NO_OPT)
    ifneq (,$(findstring gcc,$(CC)))
        CFLAGS = $(CFLAGS_DEFAULT)
    else
        CFLAGS =
    endif
else ifeq ($(CONFIG), OPT_2)
    ifneq (,$(findstring gcc,$(CC)))
        CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_2_GCC)
    else
        CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_2_CLANG)
    endif
else ifeq ($(CONFIG), OPT_3)
    ifneq (,$(findstring gcc,$(CC)))
        CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_3_GCC)
    else
        CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_3_CLANG)
    endif
else ifeq ($(CONFIG), OPT_FULL)
    ifneq (,$(findstring gcc,$(CC)))
        CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_FULL_GCC)
    else
        CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_FULL_CLANG)
    endif
endif

ifeq ($(PARALLEL), Y)
    CFLAGS += $(CFLAGS_PARALLEL)
    LDFLAGS += -fopenmp
endif

ifeq ($(DEBUG), Y)
    CFLAGS += -g -fno-omit-frame-pointer
endif

.PHONY: all clean run docs no-opt opt-2 opt-3 opt-full debug

SRC_DIR = src
LIB_DIR = lib
SOURCE = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(SOURCE:.c=.o)

TARGET = zpic

# =========================================================================== #
#                                  BUILD
# =========================================================================== #

all: $(TARGET)

$(TARGET): $(OBJ)
	$(MODULES) && \
	OMP_NUM_THREADS=$(OMP_NUM_THREADS) \
	OMP_PLACES=$(OMP_PLACES) \
	OMP_PROC_BIND=$(OMP_PROC_BIND) \
	$(CC) $(CFLAGS) $(OBJ) $(LDFLAGS) -o $@

$(SRC_DIR)/%.o: $(SRC_DIR)/%.c
	$(MODULES) && \
	$(CC) -c $(CFLAGS) -I$(LIB_DIR) $< -o $@

# =========================================================================== #
#                                  RUN
# =========================================================================== #

run: all
	@echo "=========================================="
	@echo "Running ZPIC on interactive node"
	@echo "Configuration: $(CONFIG)"
	@echo "Compiler: $(CC)"
	@echo "Threads: $(OMP_NUM_THREADS)"
	@echo "Parallel: $(PARALLEL)"
	@echo "=========================================="
	@echo "Loading modules..."
	@mkdir -p output
	@TIMESTAMP=$$(date +"%Y-%m-%d_%H-%M-%S"); \
	$(MODULES); \
	echo "Modules loaded successfully"; \
	OMP_NUM_THREADS=$(OMP_NUM_THREADS) \
	OMP_PLACES=$(OMP_PLACES) \
	OMP_PROC_BIND=$(OMP_PROC_BIND) \
	./$(TARGET) 2>&1 | tee output/zpic_run_$${TIMESTAMP}.out

# =========================================================================== #
#                                SHORTCUTS
# =========================================================================== #

no_opt:
	$(MAKE) CONFIG=NO_OPT

opt_2:
	$(MAKE) CONFIG=OPT_2

opt_3:
	$(MAKE) CONFIG=OPT_3

opt_full:
	$(MAKE) CONFIG=OPT_FULL

debug:
	$(MAKE) CONFIG=DEBUG DEBUG=Y

# =========================================================================== #
#                                DOCS
# =========================================================================== #

DOCSBASE = docs
DOCS = $(DOCSBASE)/html/index.html

docs: $(DOCS)

$(DOCS): $(SOURCE)
	@doxygen ./Doxyfile

# =========================================================================== #
#                                CLEAN
# =========================================================================== #

clean:
	rm -f $(TARGET) $(OBJ)
	rm -rf $(DOCSBASE)
