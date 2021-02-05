SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:


MAKEFLAGS := $(MAKEFLAGS)
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables


ifeq ($(origin .RECIPEPREFIX), undefined)
	$(error This Make does not support .RECIPEPREFIX. Please use GNU Make 4.0 or later)
else
	.RECIPEPREFIX = >
endif


DEFAULT_HOST	:= $(DEFAULT_HOST)
HOST		:= $(HOST)
HOST_ARCH	:= $(HOST_ARCH)
KERNEL_NAME	:= $(KERNEL_NAME)


DEST_DIR	:= $(DEST_DIR)
PREFIX		?= /usr/local
EXEC_PREFIX	:= $(PREFIX)
BOOT_DIR	?= $(EXEC_PREFIX)/boot
INCLUDE_DIR	:= $(PREFIX)/include


C_DEVELOP	:= -fstack-usage
C_DIALECT	:= -ffreestanding
C_OPTIMIZE	:= -Os
C_WARNINGS	:= -Wall -Wextra -Wformat=2 -Wswitch-default \
	-Wswitch-enum -Wcast-align -Wpointer-arith -Wbad-function-cast \
	-Wstrict-overflow=5 -Wstrict-prototypes -Winline -Wundef \
	-Wnested-externs -Wcast-qual -Wshadow -Wunreachable-code \
	-Wlogical-op -Wfloat-equal -Wstrict-aliasing=2 \
	-Wredundant-decls -Wold-style-definition -Wconversion \
	-Wdouble-promotion -Wduplicated-branches -Wduplicated-cond \
	-Wformat-truncation -Wjump-misses-init -Wnull-dereference \
	-Wrestrict -Wmissing-prototypes


CFLAGS		:= $(C_DEVELOP) $(C_DIALECT) $(C_OPTIMIZE) $(C_WARNINGS)
CPPFLAGS	:= -D__is_kernel -Iinclude
LDFLAGS		:=
LIBS		:= -nostdlib -lgcc


ARCH_DIR	:= arch/$(HOST_ARCH)
include $(ARCH_DIR)/Makefile.conf


CFLAGS		+= $(KERNEL_ARCH_CFLAGS)
CPPFLAGS	+= $(KERNEL_ARCH_CPPFLAGS)
LDFLAGS		+= $(KERNEL_ARCH_LDFLAGS)
LIBS		+= $(KERNEL_ARCH_LIBS)


KERNEL_OBJECTS	:= $(KERNEL_ARCH_OBJECTS) \
	kernel/kernel.o


OBJECTS		:= $(ARCH_DIR)/crti.o \
	$(ARCH_DIR)/crtbegin.o \
	$(KERNEL_OBJECTS) \
	$(ARCH_DIR)/crtend.o \
	$(ARCH_DIR)/crtn.o


.PHONY: all
all: $(KERNEL_NAME)


.PHONY: install
install: install-headers install-kernel


.PHONY: install-headers
install-headers:
>	mkdir -p $(DEST_DIR)/$(INCLUDE_DIR)
>	cp -R --preserve=timestamps include/. $(DEST_DIR)/$(INCLUDE_DIR)/.

.PHONY: install-kernel
install-kernel: $(KERNEL_NAME)
>	mkdir -p $(DEST_DIR)/$(BOOT_DIR)
>	cp $(KERNEL_NAME) $(DEST_DIR)/$(BOOT_DIR)


$(KERNEL_NAME): $(OBJECTS) $(ARCH_DIR)/linker.ld
>	$(CC) -T $(ARCH_DIR)/linker.ld $(CFLAGS) $(OBJECTS) $(LIBS) $(LDFLAGS) -o $@
>	grub-file --is-x86-multiboot $(KERNEL_NAME)


$(ARCH_DIR)/crtbegin.o $(ARCH_DIR)/crtend.o:
>	cp $(shell $(CC) $(CFLAGS) $(LDFLAGS) -print-file-name=$(@F)) $@


%.o: %.c
>	$(CC) -MD -c $< -o $@ $(CFLAGS) $(CPPFLAGS)


%.o: %.S
>	$(CC) -MD -c $< -o $@ $(CFLAGS) $(CPPFLAGS)


.PHONY: clean
clean:
>	rm -f $(OBJECTS)
>	rm -f $(KERNEL_NAME)
>	rm -f $(shell find -name "*.d")
>	rm -f $(shell find -name "*.su")


-include $(shell find -name "*.d")
