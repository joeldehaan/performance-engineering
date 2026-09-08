	.file	"steady.cc"
	.text
#APP
	.globl _ZSt21ios_base_library_initv
#NO_APP
	.section	.text._ZN6MatrixIdE4fillEv,"axG",@progbits,_ZN6MatrixIdE4fillEv,comdat
	.align 2
	.p2align 4
	.weak	_ZN6MatrixIdE4fillEv
	.type	_ZN6MatrixIdE4fillEv, @function
_ZN6MatrixIdE4fillEv:
.LFB8403:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA8403
	endbr64
	pushq	%r13
	.cfi_def_cfa_offset 16
	.cfi_offset 13, -16
	pushq	%r12
	.cfi_def_cfa_offset 24
	.cfi_offset 12, -24
	pushq	%rbp
	.cfi_def_cfa_offset 32
	.cfi_offset 6, -32
	pushq	%rbx
	.cfi_def_cfa_offset 40
	.cfi_offset 3, -40
	subq	$4096, %rsp
	.cfi_def_cfa_offset 4136
	orq	$0, (%rsp)
	subq	$4096, %rsp
	.cfi_def_cfa_offset 8232
	orq	$0, (%rsp)
	subq	$1848, %rsp
	.cfi_def_cfa_offset 10080
	movq	%fs:40, %r12
	movq	%r12, 10024(%rsp)
	movq	%rdi, %r12
	leaq	5024(%rsp), %rbp
	leaq	16(%rsp), %rbx
	movl	$1634100580, 5040(%rsp)
	leaq	5040(%rsp), %r13
	movq	%rbp, %rsi
	movq	%rbx, %rdi
	movl	$1953264993, 5043(%rsp)
	movq	%r13, 5024(%rsp)
	movq	$7, 5032(%rsp)
	movb	$0, 5047(%rsp)
.LEHB0:
	call	_ZNSt13random_device7_M_initERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE@PLT
.LEHE0:
	movq	5024(%rsp), %rdi
	cmpq	%r13, %rdi
	je	.L2
	movq	5040(%rsp), %rax
	leaq	1(%rax), %rsi
	call	_ZdlPvm@PLT
.L2:
	movq	%rbx, %rdi
.LEHB1:
	call	_ZNSt13random_device9_M_getvalEv@PLT
.LEHE1:
	movl	%eax, %edx
	leaq	5032(%rsp), %rcx
	movl	$1, %r9d
	movq	%rdx, 5024(%rsp)
	.p2align 6
	.p2align 4
	.p2align 3
.L7:
	movq	%rdx, %rax
	addq	$8, %rcx
	shrq	$30, %rax
	xorq	%rdx, %rax
	imulq	$1812433253, %rax, %rax
	leal	(%rax,%r9), %edx
	addq	$1, %r9
	movq	%rdx, -8(%rcx)
	cmpq	$624, %r9
	jne	.L7
	movq	8(%r12), %rax
	imulq	(%r12), %rax
	testq	%rax, %rax
	je	.L8
	movq	16(%r12), %rsi
	flds	.LC3(%rip)
	leaq	1816(%rbp), %rcx
	leaq	3168(%rbp), %rdx
	movsd	.LC1(%rip), %xmm2
	pxor	%xmm3, %xmm3
	leaq	(%rsi,%rax,8), %r8
	jmp	.L17
	.p2align 4,,10
	.p2align 3
.L36:
	divsd	8(%rsp), %xmm0
	comisd	%xmm2, %xmm0
	jnb	.L22
	addsd	%xmm3, %xmm0
.L16:
	movsd	%xmm0, (%rsi)
	addq	$8, %rsi
	cmpq	%rsi, %r8
	je	.L38
.L17:
	movl	$2, %edi
	pxor	%xmm0, %xmm0
	movsd	%xmm2, 8(%rsp)
	cmpq	$624, %r9
	je	.L9
.L37:
	movq	5024(%rsp,%r9,8), %r10
	addq	$1, %r9
.L10:
	movq	%r10, %rax
	shrq	$11, %rax
	movl	%eax, %eax
	xorq	%r10, %rax
	movq	%rax, %r10
	salq	$7, %r10
	andl	$2636928640, %r10d
	xorq	%r10, %rax
	movq	%rax, %r10
	salq	$15, %r10
	andl	$4022730752, %r10d
	xorq	%r10, %rax
	movq	%rax, %r10
	shrq	$18, %r10
	xorq	%r10, %rax
	js	.L13
	pxor	%xmm1, %xmm1
	cvtsi2sdq	%rax, %xmm1
.L14:
	mulsd	8(%rsp), %xmm1
	fld	%st(0)
	fmull	8(%rsp)
	addsd	%xmm1, %xmm0
	fstpl	8(%rsp)
	cmpl	$1, %edi
	je	.L36
	movl	$1, %edi
	cmpq	$624, %r9
	jne	.L37
.L9:
	movq	5024(%rsp), %r11
	movq	%rbp, %r9
	.p2align 6
	.p2align 4
	.p2align 3
.L11:
	andq	$-2147483648, %r11
	addq	$8, %r9
	movq	%r11, %r10
	movq	(%r9), %r11
	movq	%r11, %rax
	andl	$2147483647, %eax
	orq	%r10, %rax
	movq	%rax, %r10
	andl	$1, %eax
	negq	%rax
	shrq	%r10
	xorq	3168(%r9), %r10
	andl	$2567483615, %eax
	xorq	%r10, %rax
	movq	%rax, -8(%r9)
	cmpq	%rcx, %r9
	jne	.L11
	movq	6840(%rsp), %r11
	movq	%rbp, %r9
	.p2align 4
	.p2align 3
.L12:
	andq	$-2147483648, %r11
	addq	$8, %r9
	movq	%r11, %r10
	movq	1816(%r9), %r11
	movq	%r11, %rax
	andl	$2147483647, %eax
	orq	%r10, %rax
	movq	%rax, %r10
	andl	$1, %eax
	negq	%rax
	shrq	%r10
	xorq	-8(%r9), %r10
	andl	$2567483615, %eax
	xorq	%r10, %rax
	movq	%rax, 1808(%r9)
	cmpq	%r9, %rdx
	jne	.L12
	movq	5024(%rsp), %r10
	movq	10008(%rsp), %rax
	movq	%r10, %r9
	andq	$-2147483648, %rax
	andl	$2147483647, %r9d
	orq	%r9, %rax
	movq	%rax, %r9
	andl	$1, %eax
	negq	%rax
	shrq	%r9
	xorq	8192(%rsp), %r9
	andl	$2567483615, %eax
	xorq	%r9, %rax
	movl	$1, %r9d
	movq	%rax, 10008(%rsp)
	jmp	.L10
	.p2align 4,,10
	.p2align 3
.L13:
	movq	%rax, %r10
	andl	$1, %eax
	pxor	%xmm1, %xmm1
	shrq	%r10
	orq	%rax, %r10
	cvtsi2sdq	%r10, %xmm1
	addsd	%xmm1, %xmm1
	jmp	.L14
.L38:
	fstp	%st(0)
.L8:
	movq	%rbx, %rdi
	call	_ZNSt13random_device7_M_finiEv@PLT
	movq	10024(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L32
	addq	$10040, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 40
	popq	%rbx
	.cfi_def_cfa_offset 32
	popq	%rbp
	.cfi_def_cfa_offset 24
	popq	%r12
	.cfi_def_cfa_offset 16
	popq	%r13
	.cfi_def_cfa_offset 8
	ret
.L22:
	.cfi_restore_state
	movsd	.LC2(%rip), %xmm0
	jmp	.L16
.L4:
	movq	5024(%rsp), %rdi
	cmpq	%r13, %rdi
	je	.L5
	movq	5040(%rsp), %rax
	leaq	1(%rax), %rsi
	call	_ZdlPvm@PLT
.L5:
	movq	10024(%rsp), %rax
	subq	%fs:40, %rax
	je	.L6
.L32:
	call	__stack_chk_fail@PLT
.L23:
	endbr64
	movq	%rax, %rbp
	jmp	.L18
.L24:
	endbr64
	movq	%rax, %rbx
	jmp	.L4
.L18:
	movq	%rbx, %rdi
	call	_ZNSt13random_device7_M_finiEv@PLT
	movq	10024(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L32
	movq	%rbp, %rdi
.LEHB2:
	call	_Unwind_Resume@PLT
.L6:
	movq	%rbx, %rdi
	call	_Unwind_Resume@PLT
.LEHE2:
	.cfi_endproc
.LFE8403:
	.section	.gcc_except_table._ZN6MatrixIdE4fillEv,"aG",@progbits,_ZN6MatrixIdE4fillEv,comdat
.LLSDA8403:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE8403-.LLSDACSB8403
.LLSDACSB8403:
	.uleb128 .LEHB0-.LFB8403
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L24-.LFB8403
	.uleb128 0
	.uleb128 .LEHB1-.LFB8403
	.uleb128 .LEHE1-.LEHB1
	.uleb128 .L23-.LFB8403
	.uleb128 0
	.uleb128 .LEHB2-.LFB8403
	.uleb128 .LEHE2-.LEHB2
	.uleb128 0
	.uleb128 0
.LLSDACSE8403:
	.section	.text._ZN6MatrixIdE4fillEv,"axG",@progbits,_ZN6MatrixIdE4fillEv,comdat
	.size	_ZN6MatrixIdE4fillEv, .-_ZN6MatrixIdE4fillEv
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC5:
	.string	"\n"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB6:
	.section	.text.startup,"ax",@progbits
.LHOTB6:
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB7351:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA7351
	endbr64
	pushq	%r15
	.cfi_def_cfa_offset 16
	.cfi_offset 15, -16
	pushq	%r14
	.cfi_def_cfa_offset 24
	.cfi_offset 14, -24
	pushq	%r13
	.cfi_def_cfa_offset 32
	.cfi_offset 13, -32
	pushq	%r12
	.cfi_def_cfa_offset 40
	.cfi_offset 12, -40
	pushq	%rbp
	.cfi_def_cfa_offset 48
	.cfi_offset 6, -48
	leaq	_ZSt4cout(%rip), %rbp
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$200, %rsp
	.cfi_def_cfa_offset 256
	movq	%fs:40, %r14
	movq	%r14, 184(%rsp)
	movl	$1, %r14d
	leaq	96(%rsp), %rax
	movq	%rax, 48(%rsp)
	leaq	128(%rsp), %rax
	movq	%rax, 56(%rsp)
	leaq	160(%rsp), %rax
	movq	%rax, 64(%rsp)
.L52:
	movq	%r14, %r13
	movq	%r14, %xmm2
	imulq	%r14, %r13
	punpcklqdq	%xmm2, %xmm2
	movaps	%xmm2, (%rsp)
	movaps	%xmm2, 96(%rsp)
	leaq	0(,%r13,8), %rbx
	movq	%rbx, %rdi
	movq	%rbx, 16(%rsp)
.LEHB3:
	call	_Znam@PLT
	movq	48(%rsp), %rdi
	movq	%rax, 112(%rsp)
	movq	%rax, %r12
	call	_ZN6MatrixIdE4fillEv
.LEHE3:
	movdqa	(%rsp), %xmm2
	movq	%rbx, %rdi
	movaps	%xmm2, 128(%rsp)
.LEHB4:
	call	_Znam@PLT
	movq	56(%rsp), %rdi
	movq	%rax, 144(%rsp)
	movq	%rax, %rbx
	call	_ZN6MatrixIdE4fillEv
.LEHE4:
	movq	%r14, %rsi
	movq	%rbp, %rdi
.LEHB5:
	call	_ZNSo9_M_insertImEERSoT_@PLT
	leaq	0(,%r14,8), %r13
	movq	$5, 32(%rsp)
	leaq	(%r12,%r13), %rax
	movq	%rax, 40(%rsp)
.L47:
	call	_ZNSt6chrono3_V212steady_clock3nowEv@PLT
	movdqa	(%rsp), %xmm3
	movq	16(%rsp), %rdi
	movq	%rax, 72(%rsp)
	movaps	%xmm3, 160(%rsp)
	call	_Znam@PLT
	movq	64(%rsp), %rdi
	movq	%rax, 24(%rsp)
	movq	%rax, %r15
	movq	%rax, 176(%rsp)
	call	_ZN6MatrixIdE4fillEv
.LEHE5:
	movq	16(%rsp), %rdx
	movq	%r15, %rdi
	xorl	%esi, %esi
	call	memset@PLT
	movq	40(%rsp), %r11
	movq	%r15, %rdi
	movq	%r12, %r10
	xorl	%r15d, %r15d
	.p2align 4
	.p2align 3
.L40:
	movq	%rbx, %rsi
	xorl	%edx, %edx
	.p2align 4
	.p2align 3
.L44:
	movsd	(%rdi,%rdx,8), %xmm1
	movq	%rsi, %rcx
	movq	%r10, %rax
	.p2align 5
	.p2align 4
	.p2align 3
.L41:
	movsd	(%rax), %xmm0
	mulsd	(%rcx), %xmm0
	addq	$8, %rax
	addq	%r13, %rcx
	addsd	%xmm0, %xmm1
	cmpq	%r11, %rax
	jne	.L41
	movsd	%xmm1, (%rdi,%rdx,8)
	addq	$1, %rdx
	addq	$8, %rsi
	cmpq	%rdx, %r14
	jne	.L44
	addq	$1, %r15
	addq	%r13, %rdi
	leaq	(%rax,%r13), %r11
	addq	%r13, %r10
	cmpq	%r15, %r14
	jne	.L40
	call	_ZNSt6chrono3_V212steady_clock3nowEv@PLT
	movb	$44, 95(%rsp)
	movq	%rax, %r15
	movq	0(%rbp), %rax
	movq	-24(%rax), %rax
	cmpq	$0, 16(%rbp,%rax)
	je	.L45
	leaq	95(%rsp), %rsi
	movl	$1, %edx
	movq	%rbp, %rdi
.LEHB6:
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
	movq	%rax, %rdi
.L46:
	movq	%r15, %rsi
	subq	72(%rsp), %rsi
	call	_ZNSo9_M_insertIlEERSoT_@PLT
.LEHE6:
	movq	24(%rsp), %rdi
	call	_ZdaPv@PLT
	subq	$1, 32(%rsp)
	jne	.L47
	movl	$1, %edx
	leaq	.LC5(%rip), %rsi
	movq	%rbp, %rdi
.LEHB7:
	call	_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l@PLT
.LEHE7:
	cmpq	$299, %r14
	ja	.L48
	addq	$1, %r14
.L49:
	movq	%rbx, %rdi
	call	_ZdaPv@PLT
	movq	%r12, %rdi
	call	_ZdaPv@PLT
	jmp	.L52
.L45:
	movl	$44, %esi
	movq	%rbp, %rdi
.LEHB8:
	call	_ZNSo3putEc@PLT
.LEHE8:
	movq	%rbp, %rdi
	jmp	.L46
.L48:
	cmpq	$699, %r14
	ja	.L50
	addq	$10, %r14
	jmp	.L49
.L50:
	cmpq	$1999, %r14
	ja	.L51
	addq	$100, %r14
	jmp	.L49
.L51:
	movq	%rbx, %rdi
	call	_ZdaPv@PLT
	movq	%r12, %rdi
	call	_ZdaPv@PLT
	movq	184(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L65
	addq	$200, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 56
	xorl	%eax, %eax
	popq	%rbx
	.cfi_def_cfa_offset 48
	popq	%rbp
	.cfi_def_cfa_offset 40
	popq	%r12
	.cfi_def_cfa_offset 32
	popq	%r13
	.cfi_def_cfa_offset 24
	popq	%r14
	.cfi_def_cfa_offset 16
	popq	%r15
	.cfi_def_cfa_offset 8
	ret
.L65:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
.L60:
	endbr64
	movq	%rax, %rbp
	jmp	.L53
.L59:
	endbr64
	movq	%rax, %rbp
	jmp	.L54
.L58:
	endbr64
	movq	%rax, %rbp
	jmp	.L55
	.section	.gcc_except_table,"a",@progbits
.LLSDA7351:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE7351-.LLSDACSB7351
.LLSDACSB7351:
	.uleb128 .LEHB3-.LFB7351
	.uleb128 .LEHE3-.LEHB3
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB4-.LFB7351
	.uleb128 .LEHE4-.LEHB4
	.uleb128 .L58-.LFB7351
	.uleb128 0
	.uleb128 .LEHB5-.LFB7351
	.uleb128 .LEHE5-.LEHB5
	.uleb128 .L59-.LFB7351
	.uleb128 0
	.uleb128 .LEHB6-.LFB7351
	.uleb128 .LEHE6-.LEHB6
	.uleb128 .L60-.LFB7351
	.uleb128 0
	.uleb128 .LEHB7-.LFB7351
	.uleb128 .LEHE7-.LEHB7
	.uleb128 .L59-.LFB7351
	.uleb128 0
	.uleb128 .LEHB8-.LFB7351
	.uleb128 .LEHE8-.LEHB8
	.uleb128 .L60-.LFB7351
	.uleb128 0
.LLSDACSE7351:
	.section	.text.startup
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDAC7351
	.type	main.cold, @function
main.cold:
.LFSB7351:
.L53:
	.cfi_def_cfa_offset 256
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	movq	24(%rsp), %rdi
	call	_ZdaPv@PLT
.L54:
	movq	%rbx, %rdi
	call	_ZdaPv@PLT
.L55:
	movq	%r12, %rdi
	call	_ZdaPv@PLT
	movq	184(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L66
	movq	%rbp, %rdi
.LEHB9:
	call	_Unwind_Resume@PLT
.LEHE9:
.L66:
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE7351:
	.section	.gcc_except_table
.LLSDAC7351:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC7351-.LLSDACSBC7351
.LLSDACSBC7351:
	.uleb128 .LEHB9-.LCOLDB6
	.uleb128 .LEHE9-.LEHB9
	.uleb128 0
	.uleb128 0
.LLSDACSEC7351:
	.section	.text.unlikely
	.section	.text.startup
	.size	main, .-main
	.section	.text.unlikely
	.size	main.cold, .-main.cold
.LCOLDE6:
	.section	.text.startup
.LHOTE6:
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC1:
	.long	0
	.long	1072693248
	.align 8
.LC2:
	.long	-1
	.long	1072693247
	.section	.rodata.cst4,"aM",@progbits,4
	.align 4
.LC3:
	.long	1333788672
	.hidden	DW.ref.__gxx_personality_v0
	.weak	DW.ref.__gxx_personality_v0
	.section	.data.rel.local.DW.ref.__gxx_personality_v0,"awG",@progbits,DW.ref.__gxx_personality_v0,comdat
	.align 8
	.type	DW.ref.__gxx_personality_v0, @object
	.size	DW.ref.__gxx_personality_v0, 8
DW.ref.__gxx_personality_v0:
	.quad	__gxx_personality_v0
	.globl	__gxx_personality_v0
	.ident	"GCC: (Ubuntu 15.2.0-14ubuntu1~24~ppa1) 15.2.0"
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
