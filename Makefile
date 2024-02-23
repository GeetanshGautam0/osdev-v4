COMP = _compilers

SRCDIR = src
OBJDIR = obj
BUILDDIR = build
TOOLSDIR = tools
TOOLCOMP = comp_tools

VIRT = qemu-system-x86_64
FLOPPY = myos.img

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

ASM_SRC = $(call rwildcard,$(SRCDIR),*.asm)
C16_SRC = $(call rwildcard,$(SRCDIR),*.16c)
TLS_SRC = $(call rwildcard,$(TOOLSDIR),*.c)

ASM_OBJ = $(patsubst $(SRCDIR)/%.asm, $(OBJDIR)/%_asm.o, $(ASM_SRC))		# patsubst: Pattern Substitution
																			#			(p1, p2, iter)
																			#			p1: pattern to find
																			#			p2: pattern to replace p1 with
																			#			iter: an iterable object (list) that contains the strings to search.
C16_OBJ = $(patsubst $(SRCDIR)/%.16c, $(OBJDIR)/%_16c.o, $(C16_SRC))

TLS_OBJ = $(patsubst $(TOOLSDIR)/%.c, $(TOOLCOMP)/%.cto, $(TLS_SRC))

OBJS = $(strip $(ASM_OBJ) $(C16_OBJ))

.PHONY: clean compile bootable link hexdump run debug tools

clean:
	@echo "Clearing previous compilation..."
	bash $(COMP)/clean.sh
	@echo "Clear operation compete."
	@echo


compile: $(OBJS)

bootable:
	@echo "Making bootable floppy ..."
	bash $(COMP)/bootable.sh
	@echo
	@echo


link:
	@echo "Linking ..."
	bash $(COMP)/link.sh
	@echo
	@echo

tools: $(TLS_OBJ)

$(TOOLCOMP)/%.cto: $(TOOLSDIR)/%.c
	@echo "Compiling "$^" as a (TOOLCHAIN) C file"
	bash $(COMP)/comp_tools_c.sh $^ $@ $(@D)
	@echo
	@echo


$(OBJDIR)/%_asm.o: $(SRCDIR)/%.asm
	@echo "Compiling "$^" as an assembly file"
	mkdir -p $(@D)														# Make the destination dir
	bash $(COMP)/comp_n_asm.sh $^ $@
	@echo
	@echo

$(OBJDIR)/%_16c.o: $(SRCDIR)/%.16c
	@echo "Compiling "$^" as an 16-BIT C file"
	mkdir -p $(@D)														# Make the destination dir
	bash $(COMP)/comp_16b_c.sh $^ $@
	@echo
	@echo

hexdump:
	@echo $(FLOPPY) ":"
	@hd $(FLOPPY) > "hd.txt"
	@bash ./$(COMP)/print_file.sh "hd.txt"
	@echo
	@echo


tools: $(BUILDDIR)/tools/fat


all: clean compile link bootable hexdump


run:
	$(VIRT) -fda $(FLOPPY)

debug:
	@bash $(COMP)/debug.sh
