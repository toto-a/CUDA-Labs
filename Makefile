# Specify the compiler
NVCC = nvcc

# Specify the build directory
BIN_DIR = build

# Specify the source directory
SRC_DIR = src

# Specify the target executable
TARGET = main

# Specify the CUDA flags
CUDA_FLAGS = -g -G 

# Collect all .cu files in SRC_DIR
CU_FILES := $(wildcard $(SRC_DIR)/*.cu)

OBJ_FILES := $(patsubst $(SRC_DIR)/%.cu,$(BIN_DIR)/%.o,$(CU_FILES))

# Default target
all: $(BIN_DIR) $(TARGET)


$(BIN_DIR) :
	mkdir -p $(BIN_DIR)

# Link all object files to create the target executable
$(TARGET): $(OBJ_FILES)
	$(NVCC) $(CUDA_FLAGS) -o $(BIN_DIR)/$(TARGET)  $(OBJ_FILES)

$(BIN_DIR)/%.o: $(SRC_DIR)/%.cu
	$(NVCC) $(CUDA_FLAGS) -c $< -o $@


run : $(EXEC) 
	./$(BIN_DIR)/main

# Clean the build directory
clean:
	rm -rf $(BUILD_DIR)/*.o $(TARGET)

.PHONY: all clean