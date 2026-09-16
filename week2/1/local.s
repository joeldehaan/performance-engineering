	.file	"local.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"%ld\n"
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB23:
	.cfi_startproc
	endbr64
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$4, %edx
	movl	$2, %edi
	xorl	%eax, %eax
	leaq	.LC0(%rip), %rsi
	call	__printf_chk@PLT
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE23:
	.size	main, .-main
	.text
	.p2align 4
	.globl	func
	.type	func, @function
func:
.LFB24:
	.cfi_startproc
	endbr64
	ret
	.cfi_endproc
.LFE24:
	.size	func, .-func
	.ident	"GCC: (Ubuntu 14.2.0-4ubuntu2~24.04.1) 14.2.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	1f - 0f
	.long	4f - 1f
	.long	5
0:
	.string	"GNU"
1:
	.align 8
	.long	0xc0000002
	.long	3f - 2f
2:
	.long	0x3
3:
	.align 8
4:
