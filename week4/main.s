	.file	"main.cc"
	.text
	.section	.text._ZN6MatrixIdE4fillEv,"axG",@progbits,_ZN6MatrixIdE4fillEv,comdat
	.align 2
	.p2align 4
	.weak	_ZN6MatrixIdE4fillEv
	.type	_ZN6MatrixIdE4fillEv, @function
_ZN6MatrixIdE4fillEv:
.LFB6994:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA6994
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	andq	$-32, %rsp
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$4096, %rsp
	orq	$0, (%rsp)
	subq	$1824, %rsp
	.cfi_offset 14, -24
	.cfi_offset 13, -32
	.cfi_offset 12, -40
	.cfi_offset 3, -48
	leaq	16(%rsp), %r14
	leaq	5008(%rsp), %rbx
	movq	%rsp, %rsi
	movq	%fs:40, %r12
	movq	%r12, 10008(%rsp)
	movq	%rdi, %r12
	movl	$1634100580, 16(%rsp)
	movq	%rbx, %rdi
	movq	%r14, (%rsp)
	movl	$1953264993, 19(%rsp)
	movq	$7, 8(%rsp)
	movb	$0, 23(%rsp)
.LEHB0:
	call	_ZNSt13random_device7_M_initERKNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE@PLT
.LEHE0:
	movq	(%rsp), %rdi
	cmpq	%r14, %rdi
	je	.L2
	movq	16(%rsp), %rax
	leaq	1(%rax), %rsi
	call	_ZdlPvm@PLT
.L2:
	movq	%rbx, %rdi
.LEHB1:
	call	_ZNSt13random_device9_M_getvalEv@PLT
.LEHE1:
	movl	%eax, %ecx
	leaq	8(%rsp), %rsi
	movl	$1, %edx
	movq	%rcx, (%rsp)
	.p2align 6
	.p2align 4,,10
	.p2align 3
.L7:
	movq	%rcx, %rax
	addq	$8, %rsi
	shrq	$30, %rax
	xorq	%rcx, %rax
	imulq	$1812433253, %rax, %rax
	leal	(%rax,%rdx), %ecx
	addq	$1, %rdx
	movq	%rcx, -8(%rsi)
	cmpq	$624, %rdx
	jne	.L7
	movq	8(%r12), %rax
	imulq	(%r12), %rax
	testq	%rax, %rax
	je	.L8
	movq	16(%r12), %rsi
	vxorps	%xmm9, %xmm9, %xmm9
	vmovsd	.LC1(%rip), %xmm8
	leaq	1792(%rsp), %rcx
	vmovsd	.LC6(%rip), %xmm7
	vpbroadcastq	.LC7(%rip), %ymm4
	vpbroadcastq	.LC8(%rip), %ymm3
	vmovsd	.LC2(%rip), %xmm10
	leaq	(%rsi,%rax,8), %r8
	vpbroadcastq	.LC9(%rip), %ymm2
	jmp	.L17
	.p2align 4,,10
	.p2align 3
.L39:
	vdivsd	%xmm6, %xmm5, %xmm5
	addq	$8, %rsi
	vcmplesd	%xmm5, %xmm8, %xmm0
	vblendvpd	%xmm0, %xmm10, %xmm5, %xmm5
	vmovsd	%xmm5, -8(%rsi)
	cmpq	%r8, %rsi
	je	.L38
.L17:
	cmpq	$624, %rdx
	movl	$2, %edi
	vxorpd	%xmm5, %xmm5, %xmm5
	vmovapd	%xmm8, %xmm6
	je	.L9
.L40:
	movq	(%rsp,%rdx,8), %r9
	addq	$1, %rdx
.L10:
	movq	%r9, %rax
	shrq	$11, %rax
	movl	%eax, %eax
	xorq	%r9, %rax
	movq	%rax, %r9
	salq	$7, %r9
	andl	$2636928640, %r9d
	xorq	%r9, %rax
	movq	%rax, %r9
	salq	$15, %r9
	andl	$4022730752, %r9d
	xorq	%r9, %rax
	movq	%rax, %r9
	shrq	$18, %r9
	xorq	%r9, %rax
	vcvtsi2sdq	%rax, %xmm9, %xmm0
	jns	.L14
	movq	%rax, %r9
	andl	$1, %eax
	shrq	%r9
	orq	%rax, %r9
	vcvtsi2sdq	%r9, %xmm9, %xmm0
	vaddsd	%xmm0, %xmm0, %xmm0
.L14:
	vmulsd	%xmm6, %xmm0, %xmm0
	cmpl	$1, %edi
	vmulsd	%xmm7, %xmm6, %xmm6
	vaddsd	%xmm0, %xmm5, %xmm5
	je	.L39
	cmpq	$624, %rdx
	movl	$1, %edi
	jne	.L40
.L9:
	movq	%rsp, %rax
	.p2align 4,,10
	.p2align 3
.L11:
	vpand	(%rax), %ymm3, %ymm0
	vpand	8(%rax), %ymm4, %ymm11
	addq	$32, %rax
	vpor	%ymm0, %ymm11, %ymm11
	vpsrlq	$1, %ymm11, %ymm1
	vpand	%ymm2, %ymm11, %ymm11
	vpxor	3144(%rax), %ymm1, %ymm1
	vpsllq	$3, %ymm11, %ymm0
	vpaddq	%ymm11, %ymm0, %ymm0
	vpsllq	$9, %ymm0, %ymm0
	vpaddq	%ymm11, %ymm0, %ymm0
	vpsllq	$5, %ymm0, %ymm0
	vpaddq	%ymm11, %ymm0, %ymm0
	vpsllq	$2, %ymm0, %ymm0
	vpsubq	%ymm11, %ymm0, %ymm0
	vpsllq	$3, %ymm0, %ymm0
	vpsubq	%ymm11, %ymm0, %ymm0
	vpsllq	$4, %ymm0, %ymm12
	vpaddq	%ymm12, %ymm0, %ymm0
	vpsllq	$5, %ymm0, %ymm0
	vpsubq	%ymm11, %ymm0, %ymm0
	vpxor	%ymm0, %ymm1, %ymm1
	vmovdqa	%ymm1, -32(%rax)
	cmpq	%rcx, %rax
	jne	.L11
	movq	1800(%rsp), %rax
	movq	1792(%rsp), %rdx
	movq	%rax, %r9
	andq	$-2147483648, %rdx
	andq	$-2147483648, %rax
	andl	$2147483647, %r9d
	orq	%r9, %rdx
	movq	%rdx, %r9
	andl	$1, %edx
	negq	%rdx
	shrq	%r9
	xorq	4968(%rsp), %r9
	andl	$2567483615, %edx
	xorq	%r9, %rdx
	movq	%rdx, 1792(%rsp)
	movq	1808(%rsp), %rdx
	movq	%rdx, %r9
	andq	$-2147483648, %rdx
	andl	$2147483647, %r9d
	orq	%r9, %rax
	movq	%rax, %r9
	andl	$1, %eax
	negq	%rax
	shrq	%r9
	xorq	4976(%rsp), %r9
	andl	$2567483615, %eax
	xorq	%r9, %rax
	movq	%rax, 1800(%rsp)
	movq	1816(%rsp), %rax
	andl	$2147483647, %eax
	orq	%rdx, %rax
	movq	%rax, %rdx
	andl	$1, %eax
	negq	%rax
	shrq	%rdx
	xorq	4984(%rsp), %rdx
	andl	$2567483615, %eax
	xorq	%rdx, %rax
	leaq	4984(%rsp), %rdx
	movq	%rax, 1808(%rsp)
	leaq	1816(%rsp), %rax
	.p2align 4,,10
	.p2align 3
.L12:
	vpand	(%rax), %ymm3, %ymm0      
	vpand	8(%rax), %ymm4, %ymm11      
	addq	$32, %rax      
	vpor	%ymm0, %ymm11, %ymm11      
	vpsrlq	$1, %ymm11, %ymm1      
	vpand	%ymm2, %ymm11, %ymm11      
	vpxor	-1848(%rax), %ymm1, %ymm1      
	vpsllq	$3, %ymm11, %ymm0      
	vpaddq	%ymm11, %ymm0, %ymm0      
	vpsllq	$9, %ymm0, %ymm0      
	vpaddq	%ymm11, %ymm0, %ymm0      
	vpsllq	$5, %ymm0, %ymm0      
	vpaddq	%ymm11, %ymm0, %ymm0      
	vpsllq	$2, %ymm0, %ymm0      
	vpsubq	%ymm11, %ymm0, %ymm0      
	vpsllq	$3, %ymm0, %ymm0      
	vpsubq	%ymm11, %ymm0, %ymm0      
	vpsllq	$4, %ymm0, %ymm12      
	vpaddq	%ymm12, %ymm0, %ymm0      
	vpsllq	$5, %ymm0, %ymm0      
	vpsubq	%ymm11, %ymm0, %ymm0      
	vpxor	%ymm0, %ymm1, %ymm1      
	vmovdqu	%ymm1, -32(%rax)      
	cmpq	%rdx, %rax      
	jne	.L12
	movq	(%rsp), %r9
	movq	4984(%rsp), %rax
	movq	%r9, %rdx
	andq	$-2147483648, %rax
	andl	$2147483647, %edx
	orq	%rdx, %rax
	movq	%rax, %rdx
	andl	$1, %eax
	negq	%rax
	shrq	%rdx
	xorq	3168(%rsp), %rdx
	andl	$2567483615, %eax
	xorq	%rdx, %rax
	movl	$1, %edx
	movq	%rax, 4984(%rsp)
	jmp	.L10
.L38:
	vzeroupper
.L8:
	movq	%rbx, %rdi
	call	_ZNSt13random_device7_M_finiEv@PLT
	movq	10008(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L32
	leaq	-32(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
.L4:
	.cfi_restore_state
	movq	(%rsp), %rdi
	cmpq	%r14, %rdi
	je	.L33
	movq	16(%rsp), %rax
	leaq	1(%rax), %rsi
	vzeroupper
	call	_ZdlPvm@PLT
.L5:
	movq	10008(%rsp), %rax
	subq	%fs:40, %rax
	je	.L6
.L32:
	call	__stack_chk_fail@PLT
.L23:
	endbr64
	movq	%rax, %r12
	jmp	.L18
.L24:
	endbr64
	movq	%rax, %rbx
	jmp	.L4
.L18:
	movq	%rbx, %rdi
	vzeroupper
	call	_ZNSt13random_device7_M_finiEv@PLT
	movq	10008(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L32
	movq	%r12, %rdi
.LEHB2:
	call	_Unwind_Resume@PLT
.L33:
	vzeroupper
	jmp	.L5
.L6:
	movq	%rbx, %rdi
	call	_Unwind_Resume@PLT
.LEHE2:
	.cfi_endproc
.LFE6994:
	.section	.gcc_except_table._ZN6MatrixIdE4fillEv,"aG",@progbits,_ZN6MatrixIdE4fillEv,comdat
.LLSDA6994:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE6994-.LLSDACSB6994
.LLSDACSB6994:
	.uleb128 .LEHB0-.LFB6994
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L24-.LFB6994
	.uleb128 0
	.uleb128 .LEHB1-.LFB6994
	.uleb128 .LEHE1-.LEHB1
	.uleb128 .L23-.LFB6994
	.uleb128 0
	.uleb128 .LEHB2-.LFB6994
	.uleb128 .LEHE2-.LEHB2
	.uleb128 0
	.uleb128 0
.LLSDACSE6994:
	.section	.text._ZN6MatrixIdE4fillEv,"axG",@progbits,_ZN6MatrixIdE4fillEv,comdat
	.size	_ZN6MatrixIdE4fillEv, .-_ZN6MatrixIdE4fillEv
	.section	.rodata._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE.str1.1,"aMS",@progbits,1
.LC10:
	.string	"matrix sizes don't match"
.LC11:
	.string	"vector::reserve"
	.section	.text._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE,"axG",@progbits,_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE,comdat
	.p2align 4
	.weak	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE
	.type	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE, @function
_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE:
.LFB6997:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA6997
	endbr64
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	subq	$16, %rsp
	.cfi_def_cfa_offset 48
	cmpq	%rcx, 8(%rsi)
	jne	.L64
	movq	%rcx, %rax
	vpxor	%xmm0, %xmm0, %xmm0
	movq	$0, 16(%rdi)
	movq	%rdi, %rbx
	shrq	$60, %rax
	vmovdqu	%xmm0, (%rdi)
	jne	.L65
	testq	%rcx, %rcx
	jne	.L44
#APP
# 12 "DyMatrix/vecmult.tcc" 1
	start mat * vector
# 0 "" 2
#NO_APP
.L41:
	addq	$16, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 32
	movq	%rbx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
.L44:
	.cfi_restore_state
	leaq	0(,%rcx,8), %r10
	movq	%rdx, 8(%rsp)
	movq	%rsi, %rbp
	movq	%r10, %rdi
	movq	%r10, (%rsp)
.LEHB3:
	call	_Znwm@PLT
	movq	(%rsp), %r10
	vmovq	%rax, %xmm2
	vpunpcklqdq	%xmm2, %xmm2, %xmm0
	addq	%r10, %rax
	vmovdqu	%xmm0, (%rbx)
	movq	%rax, 16(%rbx)
#APP
# 12 "DyMatrix/vecmult.tcc" 1
	start mat * vector
# 0 "" 2
#NO_APP
	movq	8(%rbp), %rsi
	testq	%rsi, %rsi
	je	.L41
	movq	16(%rbp), %rbp
	movq	(%rbx), %r11
	xorl	%r9d, %r9d
	xorl	%edi, %edi
	movq	8(%rsp), %r8
	leaq	0(,%rsi,8), %r12
	.p2align 4,,10
	.p2align 3
.L47:
	leaq	(%r11,%rdi), %rdx
	xorl	%eax, %eax
	leaq	0(%rbp,%r9), %rcx
	vmovsd	(%rdx), %xmm1
	.p2align 5
	.p2align 4,,10
	.p2align 3
.L48:
	vmovsd	(%rcx,%rax,8), %xmm0
	vmulsd	(%r8,%rax,8), %xmm0, %xmm0
	addq	$1, %rax
	cmpq	%rsi, %rax
	vaddsd	%xmm0, %xmm1, %xmm1
	vmovsd	%xmm1, (%rdx)
	jne	.L48
	addq	$8, %rdi
	addq	%r12, %r9
	cmpq	%rdi, %r10
	jne	.L47
	addq	$16, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 32
	movq	%rbx, %rax
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
.L53:
	.cfi_restore_state
	endbr64
	movq	%rax, %rbp
	jmp	.L50
.L65:
	leaq	.LC11(%rip), %rdi
	call	_ZSt20__throw_length_errorPKc@PLT
.LEHE3:
.L64:
	movl	$16, %edi
	call	__cxa_allocate_exception@PLT
	leaq	.LC10(%rip), %rsi
	movq	%rax, %rdi
	movq	%rax, %rbx
.LEHB4:
	call	_ZNSt13runtime_errorC1EPKc@PLT
.LEHE4:
	movq	_ZNSt13runtime_errorD1Ev@GOTPCREL(%rip), %rdx
	leaq	_ZTISt13runtime_error(%rip), %rsi
	movq	%rbx, %rdi
.LEHB5:
	call	__cxa_throw@PLT
.L50:
	movq	(%rbx), %rdi
	testq	%rdi, %rdi
	jne	.L66
	vzeroupper
.L51:
	movq	%rbp, %rdi
	call	_Unwind_Resume@PLT
.L52:
	endbr64
	movq	%rax, %rbp
	jmp	.L49
.L66:
	movq	16(%rbx), %rsi
	subq	%rdi, %rsi
	vzeroupper
	call	_ZdlPvm@PLT
	jmp	.L51
.L49:
	movq	%rbx, %rdi
	vzeroupper
	call	__cxa_free_exception@PLT
	movq	%rbp, %rdi
	call	_Unwind_Resume@PLT
.LEHE5:
	.cfi_endproc
.LFE6997:
	.section	.gcc_except_table._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE,"aG",@progbits,_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE,comdat
.LLSDA6997:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE6997-.LLSDACSB6997
.LLSDACSB6997:
	.uleb128 .LEHB3-.LFB6997
	.uleb128 .LEHE3-.LEHB3
	.uleb128 .L53-.LFB6997
	.uleb128 0
	.uleb128 .LEHB4-.LFB6997
	.uleb128 .LEHE4-.LEHB4
	.uleb128 .L52-.LFB6997
	.uleb128 0
	.uleb128 .LEHB5-.LFB6997
	.uleb128 .LEHE5-.LEHB5
	.uleb128 0
	.uleb128 0
.LLSDACSE6997:
	.section	.text._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE,"axG",@progbits,_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE,comdat
	.size	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE, .-_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC12:
	.string	"basic_string: construction from null is not valid"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC13:
	.string	"stoul"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB14:
	.section	.text.startup,"ax",@progbits
.LHOTB14:
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB6460:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA6460
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
	pushq	%rbx
	.cfi_def_cfa_offset 56
	.cfi_offset 3, -56
	subq	$184, %rsp
	.cfi_def_cfa_offset 240
	movq	%fs:40, %rbp
	movq	%rbp, 168(%rsp)
	movq	8(%rsi), %rbp
	leaq	144(%rsp), %r12
	movq	%r12, 128(%rsp)
	testq	%rbp, %rbp
	je	.L133
	movq	%rbp, %rdi
	call	strlen@PLT
	cmpq	$15, %rax
	movq	%rax, %rbx
	ja	.L143
	cmpq	$1, %rax
	je	.L144
	testq	%rax, %rax
	jne	.L145
.L73:
	movq	128(%rsp), %rax
	movq	%rbx, 136(%rsp)
	movb	$0, (%rax,%rbx)
	movq	128(%rsp), %r13
	call	__errno_location@PLT
	movl	$10, %edx
	movq	%r13, %rdi
	movl	(%rax), %ebp
	movl	$0, (%rax)
	movq	%rax, %rbx
	leaq	96(%rsp), %rax
	movq	%rax, %rsi
	movq	%rax, 8(%rsp)
	call	__isoc23_strtoul@PLT
	cmpq	96(%rsp), %r13
	movq	%rax, %r15
	je	.L134
	movl	(%rbx), %eax
	cmpl	$34, %eax
	je	.L135
	testl	%eax, %eax
	jne	.L78
	movl	%ebp, (%rbx)
.L78:
	movq	128(%rsp), %rdi
	cmpq	%r12, %rdi
	je	.L79
	movq	144(%rsp), %rax
	leaq	1(%rax), %rsi
	call	_ZdlPvm@PLT
.L79:
	movq	%r15, %rax
	shrq	$60, %rax
	jne	.L136
	testq	%r15, %r15
	jne	.L87
	xorl	%edi, %edi
.LEHB6:
	call	_Znam@PLT
.LEHE6:
	movq	%rax, %rbx
	xorl	%eax, %eax
	vpxor	%xmm0, %xmm0, %xmm0
	xorl	%edi, %edi
	movq	%rax, 24(%rsp)
	xorl	%ebp, %ebp
	vmovdqa	%xmm0, 32(%rsp)
.L91:
	salq	$3, %rdi
.LEHB7:
	call	_Znam@PLT
.LEHE7:
	leaq	32(%rsp), %rdi
	movq	%rax, 48(%rsp)
	movq	%rax, %r14
.LEHB8:
	call	_ZN6MatrixIdE4fillEv
	xorl	%edx, %edx
	leaq	64(%rsp), %rdi
	leaq	32(%rsp), %rsi
	movq	%rdx, %rcx
	movq	%rbp, %rdx
	call	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE
.LEHE8:
	movq	80(%rsp), %rax
	movq	8(%rsp), %rdi
	movq	%rbx, %rdx
	movq	%r15, %rcx
	leaq	32(%rsp), %rsi
	movq	64(%rsp), %r13
	movq	%rax, 16(%rsp)
.LEHB9:
	call	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityISt4spanIS1_Lm18446744073709551615EEE4typeE
.LEHE9:
	movq	%rbx, %rdi
	call	_ZdaPv@PLT
	movq	96(%rsp), %rdi
	testq	%rdi, %rdi
	je	.L97
	movq	112(%rsp), %rsi
	subq	%rdi, %rsi
	call	_ZdlPvm@PLT
.L97:
	testq	%r13, %r13
	je	.L98
	movq	16(%rsp), %rsi
	movq	%r13, %rdi
	subq	%r13, %rsi
	call	_ZdlPvm@PLT
.L98:
	movq	%r14, %rdi
	call	_ZdaPv@PLT
	testq	%rbp, %rbp
	je	.L99
	movq	24(%rsp), %rsi
	movq	%rbp, %rdi
	subq	%rbp, %rsi
	call	_ZdlPvm@PLT
.L99:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L146
	addq	$184, %rsp
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
.L144:
	.cfi_restore_state
	movzbl	0(%rbp), %eax
	movb	%al, 144(%rsp)
	jmp	.L73
.L87:
	leaq	0(,%r15,8), %rbx
	movq	%rbx, %rdi
.LEHB10:
	call	_Znwm@PLT
.LEHE10:
	movq	%rbx, %rdi
	movq	%rax, %rbp
	leaq	(%rax,%rbx), %rax
	movq	%rax, 24(%rsp)
.LEHB11:
	call	_Znam@PLT
.LEHE11:
	vmovq	%r15, %xmm3
	movq	%r15, %rsi
	vxorps	%xmm1, %xmm1, %xmm1
	movq	%rax, %rbx
	vpunpcklqdq	%xmm3, %xmm3, %xmm2
	shrq	$3, %rsi
	xorl	%ecx, %ecx
	movabsq	$-3689348814741910323, %rdi
	.p2align 6
	.p2align 4,,10
	.p2align 3
.L93:
	xorl	%edx, %edx
	movq	%rcx, %rax
	divq	%rsi
	testq	%rdx, %rdx
	jne	.L92
	movq	%rcx, %rax
	mulq	%rdi
	shrq	$2, %rdx
	vcvtsi2sdq	%rdx, %xmm1, %xmm0
	vmovlpd	%xmm0, (%rbx,%rcx,8)
.L92:
	addq	$1, %rcx
	cmpq	%rcx, %r15
	jne	.L93
	movq	%r15, %rdi
	vmovdqa	%xmm2, 32(%rsp)
	imulq	%r15, %rdi
	movq	%rdi, %rax
	shrq	$60, %rax
	je	.L91
	jmp	.L94
.L143:
	leaq	1(%rax), %rdi
.LEHB12:
	call	_Znwm@PLT
.LEHE12:
	movq	%rbx, 144(%rsp)
	movq	%rax, 128(%rsp)
	movq	%rax, %rdi
.L71:
	movq	%rbx, %rdx
	movq	%rbp, %rsi
	call	memcpy@PLT
	jmp	.L73
.L145:
	movq	%r12, %rdi
	jmp	.L71
.L146:
	call	__stack_chk_fail@PLT
.L108:
	endbr64
	movq	%rax, %rbx
	vzeroupper
	jmp	.L103
.L113:
	endbr64
	movq	%rax, %rbx
	vzeroupper
	jmp	.L104
.L112:
	endbr64
	movq	%rax, %rbx
	vzeroupper
	jmp	.L90
.L109:
	endbr64
	movq	%rax, %rbx
	jmp	.L101
	.section	.gcc_except_table,"a",@progbits
.LLSDA6460:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE6460-.LLSDACSB6460
.LLSDACSB6460:
	.uleb128 .LEHB6-.LFB6460
	.uleb128 .LEHE6-.LEHB6
	.uleb128 .L113-.LFB6460
	.uleb128 0
	.uleb128 .LEHB7-.LFB6460
	.uleb128 .LEHE7-.LEHB7
	.uleb128 .L112-.LFB6460
	.uleb128 0
	.uleb128 .LEHB8-.LFB6460
	.uleb128 .LEHE8-.LEHB8
	.uleb128 .L108-.LFB6460
	.uleb128 0
	.uleb128 .LEHB9-.LFB6460
	.uleb128 .LEHE9-.LEHB9
	.uleb128 .L109-.LFB6460
	.uleb128 0
	.uleb128 .LEHB10-.LFB6460
	.uleb128 .LEHE10-.LEHB10
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB11-.LFB6460
	.uleb128 .LEHE11-.LEHB11
	.uleb128 .L112-.LFB6460
	.uleb128 0
	.uleb128 .LEHB12-.LFB6460
	.uleb128 .LEHE12-.LEHB12
	.uleb128 0
	.uleb128 0
.LLSDACSE6460:
	.section	.text.startup
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDAC6460
	.type	main.cold, @function
main.cold:
.LFSB6460:
.L134:
	.cfi_def_cfa_offset 240
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L147
	leaq	.LC13(%rip), %rdi
.LEHB13:
	call	_ZSt24__throw_invalid_argumentPKc@PLT
.L135:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L148
	leaq	.LC13(%rip), %rdi
	call	_ZSt20__throw_out_of_rangePKc@PLT
.LEHE13:
.L136:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L149
	leaq	.LC11(%rip), %rdi
.LEHB14:
	call	_ZSt20__throw_length_errorPKc@PLT
.L148:
	call	__stack_chk_fail@PLT
.L149:
	call	__stack_chk_fail@PLT
.L110:
	endbr64
	cmpl	$0, (%rbx)
	movq	%rax, %r13
	jne	.L82
	movl	%ebp, (%rbx)
.L82:
	movq	128(%rsp), %rdi
	cmpq	%r12, %rdi
	je	.L150
	movq	144(%rsp), %rax
	leaq	1(%rax), %rsi
	vzeroupper
	call	_ZdlPvm@PLT
.L83:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L151
	movq	%r13, %rdi
	call	_Unwind_Resume@PLT
.LEHE14:
.L94:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L152
.LEHB15:
	call	__cxa_throw_bad_array_new_length@PLT
.LEHE15:
.L101:
	testq	%r13, %r13
	je	.L141
	movq	16(%rsp), %rsi
	movq	%r13, %rdi
	subq	%r13, %rsi
	vzeroupper
	call	_ZdlPvm@PLT
.L103:
	movq	%r14, %rdi
	call	_ZdaPv@PLT
.L90:
	testq	%rbp, %rbp
	je	.L104
.L105:
	movq	24(%rsp), %rsi
	movq	%rbp, %rdi
	subq	%rbp, %rsi
	call	_ZdlPvm@PLT
.L104:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L153
	movq	%rbx, %rdi
.LEHB16:
	call	_Unwind_Resume@PLT
.L152:
	call	__stack_chk_fail@PLT
.L111:
	endbr64
	movq	%rax, %rbx
	vzeroupper
	jmp	.L105
.L153:
	call	__stack_chk_fail@PLT
.L147:
	call	__stack_chk_fail@PLT
.L133:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L154
	leaq	.LC12(%rip), %rdi
	call	_ZSt19__throw_logic_errorPKc@PLT
.LEHE16:
.L154:
	call	__stack_chk_fail@PLT
.L150:
	vzeroupper
	jmp	.L83
.L151:
	call	__stack_chk_fail@PLT
.L141:
	vzeroupper
	jmp	.L103
	.cfi_endproc
.LFE6460:
	.section	.gcc_except_table
.LLSDAC6460:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC6460-.LLSDACSBC6460
.LLSDACSBC6460:
	.uleb128 .LEHB13-.LCOLDB14
	.uleb128 .LEHE13-.LEHB13
	.uleb128 .L110-.LCOLDB14
	.uleb128 0
	.uleb128 .LEHB14-.LCOLDB14
	.uleb128 .LEHE14-.LEHB14
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB15-.LCOLDB14
	.uleb128 .LEHE15-.LEHB15
	.uleb128 .L111-.LCOLDB14
	.uleb128 0
	.uleb128 .LEHB16-.LCOLDB14
	.uleb128 .LEHE16-.LEHB16
	.uleb128 0
	.uleb128 0
.LLSDACSEC6460:
	.section	.text.unlikely
	.section	.text.startup
	.size	main, .-main
	.section	.text.unlikely
	.size	main.cold, .-main.cold
.LCOLDE14:
	.section	.text.startup
.LHOTE14:
	.section	.rodata.cst8,"aM",@progbits,8
	.align 8
.LC1:
	.long	0
	.long	1072693248
	.align 8
.LC2:
	.long	-1
	.long	1072693247
	.align 8
.LC6:
	.long	0
	.long	1106247680
	.align 8
.LC7:
	.quad	2147483647
	.align 8
.LC8:
	.quad	-2147483648
	.align 8
.LC9:
	.quad	1
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
