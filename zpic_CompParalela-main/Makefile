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

OMP_NUM_THREADS?=48 # ! Change this to achieve best performance
OMP_PLACES?=cores
OMP_PROC_BIND?=close 

# ======================= FLAGS and Inputs ============================================ #

MAKEFLAGS += --no-print-directory

CC ?= gcc # Compiler (Other options would include Fujistu Compiler for A64FX )

CFLAGS_DEFAULT = -std=c99 -pedantic -Wall
CFLAGS_OPT_1 = -O2 -march=native
CFLAGS_OPT_2 = -O3 -march=native
CFLAGS_OPT_FULL = -Ofast -march=native -mtune=a64fx -flto # Allows FMA's and Cross file optimizations (For future work add more accordingly to hotspots that might be needed to be fixed) 
LDFLAGS = -lm

# Inputs by user ! CONFIG = <config>, PARALLEL = <Y/N>
CONFIG ?= DEFAULT 
PARALLEL ?= N
DEBUG ?= N

# Choose CFLAGS
ifeq ($(CONFIG), NO_OPT)
	CFLAGS = $(CFLAGS_DEFAULT)
else ifeq ($(CONFIG), OPT_2)
	CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_2)
else ifeq ($(CONFIG), OPT_3)
	CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_3)
else ifeq ($(CONFIG), OPT_FULL)
	CFLAGS = $(CFLAGS_DEFAULT) $(CFLAGS_OPT_FULL)
else 
	CFLAGS = $(CFLAGS_DEFAULT)
endif

# Choose programming model (Sequential vs Parallelism) 
ifeq ($(PARALLEL), Y)
	CFLAGS += -fopenmp
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
