COMPILADOR = nasm
FLAGS = -f elf64 -g -F dwarf
ARQUIVO = tarefa3-Grupo6.asm

all: Artifacts/programa

# -----

Artifacts:
	mkdir -p Artifacts

Artifacts/main.o: $(ARQUIVO) | Artifacts
	$(COMPILADOR) $(FLAGS) $< -o $@

Artifacts/programa: Artifacts/main.o
	ld -o Artifacts/programa Artifacts/main.o

# -----

build: all

# -----

clean:
	rm -f Artifacts/main.o Artifacts/programa

# -----

run: Artifacts/programa
	./Artifacts/programa

# -----

.PHONY: all build run clean