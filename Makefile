COMPILADOR = nasm
FLAGS = -f elf64 -g -F dwarf
ARQUIVO = input_output.asm

all: Artifacts/main.o Artifacts/programa

# -----

Artifacts/main.o: $(ARQUIVO)
	$(COMPILADOR) $(FLAGS) $< -o $@

Artifacts/programa: Artifacts/main.o
	ld -o Artifacts/programa Artifacts/main.o

# -----

build: all

# -----

clean:
	rm -f Artifacts/main.o Artifacts/programa

# -----

rebuild: clean all # lembrar de apagar quando o programa estiver completo

# -----

run: Artifacts/programa
	./Artifacts/programa

# -----

.PHONY: all build run clean rebuid