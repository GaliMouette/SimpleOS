# Declarations for multiboot header
.set ALIGN,	1 << 0			# Align loaded modules on 4k pages
.set MEM_INFO,	1 << 1			# Tell grub to provide memory map
.set FLAGS,	ALIGN | MEM_INFO	# Multiboot flag field
.set MAGIC,	0x1BADB002		# Multiboot magic number
.set CHECKSUM,	-(MAGIC + FLAGS)	# Checksum to prove we are in multiboot header


# Multiboot header declaration
.section .multiboot
.align 4
.long MAGIC
.long FLAGS
.long CHECKSUM


# Allocate 16 ko of stack
.section .bss
.align 16
stack_bottom:
.skip 16384
stack_top:


# Start the kernel
.section .text
.global _start
.type _start, @function
_start:
	movl $stack_top, %esp
	call main	# call to main kernel function
	cli		# Disable interruptions
loop_inf:
	jmp loop_inf

.size _start, . - _start
