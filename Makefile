true:
	@echo "."

SRCDIR1 = dev/kernel/kernel
SRCDIR2 = dev/kernel/include
SRCDIR3 = dev/kernel/arch/i386
LIBC = dev/libc

OBJDIR = lib/i386
C_COMPILER = ./n_cpp.sh

rwildcard=$(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$d,$2) $(filter $(subst *,%,$2),$d))

CPP_SRC1 = $(call rwildcard,$(SRCDIR1),*.cpp)
CPP_SRC2 = $(call rwildcard,$(SRCDIR2),*.cpp)
CPP_SRC3 = $(call rwildcard,$(SRCDIR3),*.cpp)
C_SRC1 = $(call rwildcard,$(SRCDIR1),*.c)
C_SRC2 = $(call rwildcard,$(SRCDIR2),*.c)
C_SRC3 = $(call rwildcard,$(SRCDIR3),*.c)
L_SRC1 = $(call rwildcard,$(LIBC),*.c)
L_SRC2 = $(call rwildcard,$(LIBC),*.cpp)

OBJS1 = $(patsubst $(SRCDIR1)/%.c, $(OBJDIR)/%_c1.o, $(C_SRC1))
OBJS2 = $(patsubst $(SRCDIR2)/%.c, $(OBJDIR)/%_c2.o, $(C_SRC2))
OBJS3 = $(patsubst $(SRCDIR3)/%.c, $(OBJDIR)/%_c3.o, $(C_SRC3))
OBJS4 = $(patsubst $(SRCDIR1)/%.cpp, $(OBJDIR)/%_cpp1.o, $(CPP_SRC1))
OBJS5 = $(patsubst $(SRCDIR2)/%.cpp, $(OBJDIR)/%_cpp2.o, $(CPP_SRC2))
OBJS6 = $(patsubst $(SRCDIR3)/%.cpp, $(OBJDIR)/%_cpp3.o, $(CPP_SRC3))
OBJS7 = $(patsubst $(LIBC)/%.c, $(OBJDIR)/%_libc1.o, $(L_SRC1))
OBJS8 = $(patsubst $(LIBC)/%.cpp, $(OBJDIR)/%_libc2.o, $(L_SRC2))

OBJS = $(strip $(OBJS1) $(OBJS2) $(OBJS3) $(OBJS4) $(OBJS5) $(OBJS6) $(OBJS7) $(OBJS8))
CPP_SRC = $(strip $(CPP_SRC1) $(CPP_SRC2) $(CPP_SRC3) $(L_SRC2))
C_SRC = $(strip $(C_SRC1) $(C_SRC2) $(C_SRC3) $(L_SRC1))

help:
	@grep -B1 -E "^[a-zA-Z0-9_-]+\:([^\=]|$$)" Makefile \
     | grep -v -- -- \
     | sed 'N;s/\n/###/' \
     | sed -n 's/^#: \(.*\)###\(.*\):.*/\2###\1/p' \
     | column -t  -s '###'

#: debug
debug:
	@echo "USING ARCH i386"

	@echo "OBJ: $(OBJS)"
	@echo "CPP: $(CPP_SRC)"
	@echo "C  : $(C_SRC)"


$(OBJDIR)/%_cpp1.o: $(SRCDIR1)/%.cpp
	@echo !--- Compiling "$^" ---!
	@mkdir -p $(@D)
	@bash $(C_COMPILER) $^ $@

$(OBJDIR)/%_cpp2.o: $(SRCDIR2)/%.cpp
	@echo !--- Compiling "$^" ---!
	@mkdir -p $(@D)
	@bash $(C_COMPILER) $^ $@

$(OBJDIR)/%_cpp3.o: $(SRCDIR3)/%.cpp
	@echo !--- Compiling "$^" ---!
	@mkdir -p $(@D)
	@bash $(C_COMPILER) $^ $@

$(OBJDIR)/%_c1.o: $(SRCDIR1)/%.c
	@echo !--- Compiling "$^" ---!
	@mkdir -p $(@D)
	@bash $(C_COMPILER) $^ $@

$(OBJDIR)/%_c2.o: $(SRCDIR2)/%.c
	@echo !--- Compiling "$^" ---!
	@mkdir -p $(@D)
	@bash $(C_COMPILER) $^ $@

$(OBJDIR)/%_libc1.o: $(LIBC)/%.c
	@echo !--- Compiling "$^" ---!
	@mkdir -p $(@D)
	@bash $(C_COMPILER) $^ $@

$(OBJDIR)/%_libc2.o: $(LIBC)/%.cpp
	@echo !--- Compiling "$^" ---!
	@mkdir -p $(@D)
	@bash $(C_COMPILER) $^ $@

compile: true $(OBJS)

#: bootloader
bootloader: true
	bash ./bootloader.sh

#: clean
clean: true
	bash ./clean.sh

#: link
link: true
	bash ./link.sh

verify_mb: true
	bash ./verify_multiboot.sh

mk_image: true
	bash ./image.sh

run: true
	bash ./run.sh

all: debug clean bootloader compile link verify_mb mk_image
