# =========================================================================== #
#  Makefile - ZPIC Project
# =========================================================================== #
# - University - University of Minho
# - Course - Parallel Computing (MCA)
# - Authors - Diogo Silva & Tomás Pereira 
# ============================================================================= #
# - Configurations you can use:
# 
# %%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#     OPTIMIZATIONS LEVELS     #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# ------------------------------------
# - NO_OPT - No optimizations
# -------------------------------------
# - OPT_2 - Uses -O2 and march = native
# -------------------------------------
# - OPT_3 - Uses -O3 and march = native
# --------------------------------------
# - OPT_FULL - Uses all optimizations
# --------------------------------------
#
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
#   		DEBUGGING            #
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%% #
# ------------------------------------------------
# - Y / N - Yes or no to make code easier to debug
# ------------------------------------------------
# ========================================================================== #

# ==================== MAKEFILE code ======================================= #

# ====================== OMP SETTINGS ====================================== #

OMP_NUM_THREADS?=12 # Best PU performance (Best times with CLANG 12s vs 14s)
OMP_PLACES?=cores
OMP_PROC_BIND?=close 

# ======================= FLAGS and Inputs ============================================ #

MAKEFLAGS += --no-print-directory

CC ?= gcc # Compiler

CFLAGS_DEFAULT = -std=c99 -pedantic -Wall
CFLAGS_OPT_2_GCC = -O2 -march=native
CFLAGS_OPT_2_CLANG = -O2 -mcpu=a64fx -msve-vector-bits=512
CFLAGS_OPT_3_GCC = -O3 -march=native 
CFLAGS_OPT_3_CLANG = -O3 -mcpu=a64fx -msve-vector-bits=512
CFLAGS_OPT_FULL_GCC = -Ofast -march=native
CFLAGS_OPT_FULL_CLANG= -O3 -ffast-math -mcpu=a64fx -msve-vector-bits=512 -Rpass=loop-vectorize -Rpass-analysis=loop-vectorize 

CFLAGS_PARALLEL = -fopenmp

LDFLAGS = -lm 

# Inputs by user
CONFIG ?= OPT_FULL
PARALLEL ?= N
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
        CFLAGS = $(CFLAGS_OPT_2_CLANG)
    endif
else ifeq ($(CONFIG), OPT_3)
    ifneq (,$(findstring gcc,$(CC)))
        CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_3_GCC)
    else
        CFLAGS = $(CFLAGS_OPT_3_CLANG)
    endif
else ifeq ($(CONFIG), OPT_FULL)
    ifneq (,$(findstring gcc,$(CC)))
        CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_FULL_GCC)
    else
        CFLAGS = $(CFLAGS_OPT_FULL_CLANG)
    endif
endif

# Add OpenMP if parallel is Y
ifeq ($(PARALLEL), Y)
    CFLAGS += $(CFLAGS_PARALLEL)
    LDFLAGS += -fopenmp
endif


# Debugging
ifeq ($(DEBUG), Y)
	CFLAGS += -g -fno-omit-frame-pointer
endif 

# =========================================================================== #

# =========================== TARGETS ======================================= #

.PHONY: all clean run docs no-opt opt-2 opt-3 opt-full debug 

SRC_DIR = src
LIB_DIR = lib
SOURCE = $(wildcard $(SRC_DIR)/*.c)
OBJ = $(SOURCE:.c=.o)

TARGET = zpic

all: $(TARGET)

$(TARGET): $(OBJ)
	OMP_NUM_THREADS=$(OMP_NUM_THREADS) OMP_PLACES=$(OMP_PLACES) OMP_PROC_BIND=$(OMP_PROC_BIND) \
	$(CC) $(CFLAGS) $(OBJ) $(LDFLAGS) -o $@

$(SRC_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) -c $(CFLAGS) -I$(LIB_DIR) $< -o $@

run: all
	@echo "Best case possible (TODO)"

no_opt:
	@echo "Running with no optimizations..."
	$(MAKE) CONFIG=NO_OPT

opt_2:
	@echo "Running with -O2...."
	$(MAKE) CONFIG=OPT_2

opt_3:
	@echo "Running with -O3"
	$(MAKE) CONFIG=OPT_3

opt_full:
	@echo "Running with -Ofast"
	$(MAKE) CONFIG=OPT_FULL

debug:
	$(MAKE) CONFIG=DEBUG DEBUG=Y

# Documentation
DOCSBASE = docs

DOCS = $(DOCSBASE)/html/index.html

docs: $(DOCS)
$(DOCS): $(SOURCE)
	@doxygen ./Doxyfile

# Cleaning
clean:
	rm -f $(TARGET) $(OBJ)
	rm -rf $(DOCSBASE)
