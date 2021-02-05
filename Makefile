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


PROJECTS = kernel


export DEFAULT_HOST	:= i686-elf
export HOST		:= $(DEFAULT_HOST)
export OS_NAME		:= SimpleOS
export KERNEL_NAME	:= SimpleKernel


export AR := $(HOST)-ar
export AS := $(HOST)-as
export CC := $(HOST)-gcc


export PREFIX		:= /usr
export EXEC_PREFIX	:= $(PREFIX)
export BOOT_DIR		:= /boot
export LIB_DIR		:= $(EXEC_PREFIX)/lib
export INCLUDE_DIR	:= $(PREFIX)/include


export SYSROOT = $(CURDIR)/sysroot
CC += --sysroot=$(SYSROOT)


ifeq ($(shell echo $(HOST) | grep -Eq -- '-elf($$|-)'; echo $$?), 0)
	CC += -isystem=$(INCLUDE_DIR)
endif


export HOST_ARCH :=
ifeq ($(shell echo $(HOST) | grep -Eq 'i[[:digit:]]86-'; echo $$?), 0)
	HOST_ARCH := i386
else
	HOST_ARCH := $(shell echo $(HOST) | grep -Eo '^[[:alnum:]_]*')
endif


.PHONY: all
all: build


.PHONY: build
build: headers
>	mkdir -p $(SYSROOT)
>	export DEST_DIR=$(SYSROOT)
>	$(foreach project, $(PROJECTS), $(MAKE) -C $(project) install &&) true
>	unset DEST_DIR


.PHONY: headers
headers:
>	mkdir -p $(SYSROOT)
>	export DEST_DIR=$(SYSROOT)
>	$(foreach project, $(PROJECTS), $(MAKE) -C $(project) install-headers &&) true
>	unset DEST_DIR


.PHONY: iso
iso: build
>	mkdir -p isodir/boot/grub
>	cp $(SYSROOT)/boot/$(KERNEL_NAME) isodir/boot/$(KERNEL_NAME)
>	echo -e "menuentry \"OS\" {\n\tmultiboot /boot/$(KERNEL_NAME)\n}" > isodir/boot/grub/grub.cfg
>	grub-mkrescue -o $(OS_NAME).iso isodir


.PHONY: qemu
qemu: iso
>	qemu-system-$(HOST_ARCH) -cdrom $(OS_NAME).iso


.PHONY: clean
clean:
>	$(foreach project, $(PROJECTS), $(MAKE) -C $(project) clean &&) true
>	rm -fr sysroot
>	rm -fr isodir
>	rm -f $(OS_NAME).iso
