NVCC=nvcc
CUDAFLAGS=-std=c++20

BIN=main
SRC=src/main.cc \
	src/game_of_life.cu

TRASHFILES=

all: $(BIN)

$(BIN): $(SRC)
	$(NVCC) $(CUDAFLAGS) -o $@ $^

clean:
	$(RM) $(BIN)

.gitignore:
	$(RM) $@
	for FILE in '# binaries' $(BIN) '# trashfiles' $(TRASHFILES); do echo $${FILE} >> $@; done

.PHONY: all clean
