	.file	"main.cc"
	.text
	.section	.text._ZN6MatrixIdE4fillEv,"axG",@progbits,_ZN6MatrixIdE4fillEv,comdat
	.align 2
	.p2align 4
	.weak	_ZN6MatrixIdE4fillEv
	.type	_ZN6MatrixIdE4fillEv, @function
_ZN6MatrixIdE4fillEv:
.LFB7006:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA7006
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
.LFE7006:
	.section	.gcc_except_table._ZN6MatrixIdE4fillEv,"aG",@progbits,_ZN6MatrixIdE4fillEv,comdat
.LLSDA7006:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE7006-.LLSDACSB7006
.LLSDACSB7006:
	.uleb128 .LEHB0-.LFB7006
	.uleb128 .LEHE0-.LEHB0
	.uleb128 .L24-.LFB7006
	.uleb128 0
	.uleb128 .LEHB1-.LFB7006
	.uleb128 .LEHE1-.LEHB1
	.uleb128 .L23-.LFB7006
	.uleb128 0
	.uleb128 .LEHB2-.LFB7006
	.uleb128 .LEHE2-.LEHB2
	.uleb128 0
	.uleb128 0
.LLSDACSE7006:
	.section	.text._ZN6MatrixIdE4fillEv,"axG",@progbits,_ZN6MatrixIdE4fillEv,comdat
	.size	_ZN6MatrixIdE4fillEv, .-_ZN6MatrixIdE4fillEv
	.section	.rodata._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE.str1.1,"aMS",@progbits,1
.LC10:
	.string	"matrix sizes don't match"
	.section	.rodata._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE.str1.8,"aMS",@progbits,1
	.align 8
.LC11:
	.string	"cannot create std::vector larger than max_size()"
	.section	.text._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE,"axG",@progbits,_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE,comdat
	.p2align 4
	.weak	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE
	.type	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE, @function
_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE:
.LFB7009:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA7009
	endbr64
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	andq	$-32, %rsp
	subq	$32, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	movq	8(%rsi), %r13
	movq	(%rsi), %rax
	cmpq	%rcx, %r13
	jne	.L68
	movq	%rsi, %r8
	movq	%rax, %rsi
	shrq	$60, %rsi
	jne	.L69
	testq	%rax, %rax
	movq	%rdi, %r12
	movq	%rdx, %rbx
	movq	%rcx, %r15
	je	.L70
	leaq	0(,%rax,8), %r14
	movq	%r8, 16(%rsp)
	movq	%r14, %rdi
.LEHB3:
	call	_Znwm@PLT
	movq	%r14, %rdx
	xorl	%esi, %esi
	leaq	(%rax,%r14), %r9
	movq	%rax, (%r12)
	movq	%rax, %rdi
	movq	%r9, 16(%r12)
	movq	%r9, 24(%rsp)
	call	memset@PLT
	movq	24(%rsp), %r9
	movq	16(%rsp), %r8
	movq	%rax, %rcx
.L45:
	movq	%r9, 8(%r12)
	movq	%rcx, %rsi
	leaq	(%rcx,%r15,8), %r9
	movq	%r13, %rcx
	shrq	$2, %rcx
	movq	16(%r8), %r8
	leaq	-1(%r13), %r10
	xorl	%edi, %edi
	salq	$5, %rcx
	.p2align 4,,10
	.p2align 3
.L46:
	cmpq	$2, %r10
	jbe	.L56
.L48:
	leaq	(%r8,%rdi,8), %rdx
	xorl	%eax, %eax
	vxorpd	%xmm1, %xmm1, %xmm1
	.p2align 5
	.p2align 4,,10
	.p2align 3
.L52:
	vmovupd	(%rbx,%rax), %ymm0
	vmulpd	(%rdx,%rax), %ymm0, %ymm0
	addq	$32, %rax
	cmpq	%rax, %rcx
	vaddpd	%ymm0, %ymm1, %ymm1
	jne	.L52
	vextractf128	$0x1, %ymm1, %xmm0
	testb	$3, %r13b
	vaddpd	%xmm1, %xmm0, %xmm0
	vunpckhpd	%xmm0, %xmm0, %xmm1
	vaddpd	%xmm0, %xmm1, %xmm1
	je	.L71
	movq	%r13, %rax
	andq	$-4, %rax
.L54:
	movq	%r13, %rdx
	subq	%rax, %rdx
	cmpq	$1, %rdx
	je	.L50
	leaq	(%rdi,%rax), %r11
	vmovupd	(%rbx,%rax,8), %xmm2
	testb	$1, %dl
	vfmadd231pd	(%r8,%r11,8), %xmm2, %xmm0
	vunpckhpd	%xmm0, %xmm0, %xmm1
	vaddpd	%xmm0, %xmm1, %xmm1
	je	.L51
	andq	$-2, %rdx
	addq	%rdx, %rax
.L50:
	leaq	(%rdi,%rax), %rdx
	vmovsd	(%r8,%rdx,8), %xmm3
	vfmadd231sd	(%rbx,%rax,8), %xmm3, %xmm1
.L51:
	vmovsd	%xmm1, (%rsi)
	addq	$8, %rsi
	addq	%r13, %rdi
	cmpq	%r9, %rsi
	jne	.L46
.L41:
	vzeroupper
	leaq	-40(%rbp), %rsp
	movq	%r12, %rax
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_remember_state
	.cfi_def_cfa 7, 8
	ret
	.p2align 4,,10
	.p2align 3
.L71:
	.cfi_restore_state
	vmovsd	%xmm1, (%rsi)
	addq	$8, %rsi
	addq	%r13, %rdi
	cmpq	%r9, %rsi
	jne	.L48
	jmp	.L41
	.p2align 4,,10
	.p2align 3
.L56:
	vxorpd	%xmm0, %xmm0, %xmm0
	xorl	%eax, %eax
	vxorpd	%xmm1, %xmm1, %xmm1
	jmp	.L54
.L70:
	movq	$0, (%rdi)
	xorl	%ecx, %ecx
	xorl	%r9d, %r9d
	movq	$0, 16(%rdi)
	jmp	.L45
.L69:
	leaq	.LC11(%rip), %rdi
	call	_ZSt20__throw_length_errorPKc@PLT
.LEHE3:
.L68:
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
.L57:
	endbr64
	movq	%rax, %r12
.L55:
	movq	%rbx, %rdi
	vzeroupper
	call	__cxa_free_exception@PLT
	movq	%r12, %rdi
	call	_Unwind_Resume@PLT
.LEHE5:
	.cfi_endproc
.LFE7009:
	.section	.gcc_except_table._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE,"aG",@progbits,_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE,comdat
.LLSDA7009:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE7009-.LLSDACSB7009
.LLSDACSB7009:
	.uleb128 .LEHB3-.LFB7009
	.uleb128 .LEHE3-.LEHB3
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB4-.LFB7009
	.uleb128 .LEHE4-.LEHB4
	.uleb128 .L57-.LFB7009
	.uleb128 0
	.uleb128 .LEHB5-.LFB7009
	.uleb128 .LEHE5-.LEHB5
	.uleb128 0
	.uleb128 0
.LLSDACSE7009:
	.section	.text._ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE,"axG",@progbits,_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE,comdat
	.size	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE, .-_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE
	.section	.rodata.str1.8,"aMS",@progbits,1
	.align 8
.LC12:
	.string	"basic_string: construction from null is not valid"
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC13:
	.string	"stoul"
.LC14:
	.string	"vector::reserve"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB15:
	.section	.text.startup,"ax",@progbits
.LHOTB15:
	.p2align 4
	.globl	main
	.type	main, @function
main:
.LFB6461:
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDA6461
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
	je	.L138
	movq	%rbp, %rdi
	call	strlen@PLT
	cmpq	$15, %rax
	movq	%rax, %rbx
	ja	.L148
	cmpq	$1, %rax
	je	.L149
	testq	%rax, %rax
	jne	.L150
.L78:
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
	je	.L139
	movl	(%rbx), %eax
	cmpl	$34, %eax
	je	.L140
	testl	%eax, %eax
	jne	.L83
	movl	%ebp, (%rbx)
.L83:
	movq	128(%rsp), %rdi
	cmpq	%r12, %rdi
	je	.L84
	movq	144(%rsp), %rax
	leaq	1(%rax), %rsi
	call	_ZdlPvm@PLT
.L84:
	movq	%r15, %rax
	shrq	$60, %rax
	jne	.L141
	testq	%r15, %r15
	jne	.L92
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
.L96:
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
	call	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE
.LEHE8:
	movq	80(%rsp), %rax
	movq	8(%rsp), %rdi
	movq	%rbx, %rdx
	movq	%r15, %rcx
	leaq	32(%rsp), %rsi
	movq	64(%rsp), %r13
	movq	%rax, 16(%rsp)
.LEHB9:
	call	_ZmlIdESt6vectorIT_SaIS1_EERK6MatrixIS1_ENSt13type_identityIKSt4spanIKS1_Lm18446744073709551615EEE4typeE
.LEHE9:
	movq	%rbx, %rdi
	call	_ZdaPv@PLT
	movq	96(%rsp), %rdi
	testq	%rdi, %rdi
	je	.L102
	movq	112(%rsp), %rsi
	subq	%rdi, %rsi
	call	_ZdlPvm@PLT
.L102:
	testq	%r13, %r13
	je	.L103
	movq	16(%rsp), %rsi
	movq	%r13, %rdi
	subq	%r13, %rsi
	call	_ZdlPvm@PLT
.L103:
	movq	%r14, %rdi
	call	_ZdaPv@PLT
	testq	%rbp, %rbp
	je	.L104
	movq	24(%rsp), %rsi
	movq	%rbp, %rdi
	subq	%rbp, %rsi
	call	_ZdlPvm@PLT
.L104:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L151
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
.L149:
	.cfi_restore_state
	movzbl	0(%rbp), %eax
	movb	%al, 144(%rsp)
	jmp	.L78
.L92:
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
.L98:
	xorl	%edx, %edx
	movq	%rcx, %rax
	divq	%rsi
	testq	%rdx, %rdx
	jne	.L97
	movq	%rcx, %rax
	mulq	%rdi
	shrq	$2, %rdx
	vcvtsi2sdq	%rdx, %xmm1, %xmm0
	vmovlpd	%xmm0, (%rbx,%rcx,8)
.L97:
	addq	$1, %rcx
	cmpq	%rcx, %r15
	jne	.L98
	movq	%r15, %rdi
	vmovdqa	%xmm2, 32(%rsp)
	imulq	%r15, %rdi
	movq	%rdi, %rax
	shrq	$60, %rax
	je	.L96
	jmp	.L99
.L148:
	leaq	1(%rax), %rdi
.LEHB12:
	call	_Znwm@PLT
.LEHE12:
	movq	%rbx, 144(%rsp)
	movq	%rax, 128(%rsp)
	movq	%rax, %rdi
.L76:
	movq	%rbx, %rdx
	movq	%rbp, %rsi
	call	memcpy@PLT
	jmp	.L78
.L150:
	movq	%r12, %rdi
	jmp	.L76
.L151:
	call	__stack_chk_fail@PLT
.L113:
	endbr64
	movq	%rax, %rbx
	vzeroupper
	jmp	.L108
.L118:
	endbr64
	movq	%rax, %rbx
	vzeroupper
	jmp	.L109
.L117:
	endbr64
	movq	%rax, %rbx
	vzeroupper
	jmp	.L95
.L114:
	endbr64
	movq	%rax, %rbx
	jmp	.L106
	.section	.gcc_except_table,"a",@progbits
.LLSDA6461:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSE6461-.LLSDACSB6461
.LLSDACSB6461:
	.uleb128 .LEHB6-.LFB6461
	.uleb128 .LEHE6-.LEHB6
	.uleb128 .L118-.LFB6461
	.uleb128 0
	.uleb128 .LEHB7-.LFB6461
	.uleb128 .LEHE7-.LEHB7
	.uleb128 .L117-.LFB6461
	.uleb128 0
	.uleb128 .LEHB8-.LFB6461
	.uleb128 .LEHE8-.LEHB8
	.uleb128 .L113-.LFB6461
	.uleb128 0
	.uleb128 .LEHB9-.LFB6461
	.uleb128 .LEHE9-.LEHB9
	.uleb128 .L114-.LFB6461
	.uleb128 0
	.uleb128 .LEHB10-.LFB6461
	.uleb128 .LEHE10-.LEHB10
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB11-.LFB6461
	.uleb128 .LEHE11-.LEHB11
	.uleb128 .L117-.LFB6461
	.uleb128 0
	.uleb128 .LEHB12-.LFB6461
	.uleb128 .LEHE12-.LEHB12
	.uleb128 0
	.uleb128 0
.LLSDACSE6461:
	.section	.text.startup
	.cfi_endproc
	.section	.text.unlikely
	.cfi_startproc
	.cfi_personality 0x9b,DW.ref.__gxx_personality_v0
	.cfi_lsda 0x1b,.LLSDAC6461
	.type	main.cold, @function
main.cold:
.LFSB6461:
.L139:
	.cfi_def_cfa_offset 240
	.cfi_offset 3, -56
	.cfi_offset 6, -48
	.cfi_offset 12, -40
	.cfi_offset 13, -32
	.cfi_offset 14, -24
	.cfi_offset 15, -16
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L152
	leaq	.LC13(%rip), %rdi
.LEHB13:
	call	_ZSt24__throw_invalid_argumentPKc@PLT
.L140:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L153
	leaq	.LC13(%rip), %rdi
	call	_ZSt20__throw_out_of_rangePKc@PLT
.LEHE13:
.L141:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L154
	leaq	.LC14(%rip), %rdi
.LEHB14:
	call	_ZSt20__throw_length_errorPKc@PLT
.L153:
	call	__stack_chk_fail@PLT
.L154:
	call	__stack_chk_fail@PLT
.L115:
	endbr64
	cmpl	$0, (%rbx)
	movq	%rax, %r13
	jne	.L87
	movl	%ebp, (%rbx)
.L87:
	movq	128(%rsp), %rdi
	cmpq	%r12, %rdi
	je	.L155
	movq	144(%rsp), %rax
	leaq	1(%rax), %rsi
	vzeroupper
	call	_ZdlPvm@PLT
.L88:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L156
	movq	%r13, %rdi
	call	_Unwind_Resume@PLT
.LEHE14:
.L99:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L157
.LEHB15:
	call	__cxa_throw_bad_array_new_length@PLT
.LEHE15:
.L106:
	testq	%r13, %r13
	je	.L146
	movq	16(%rsp), %rsi
	movq	%r13, %rdi
	subq	%r13, %rsi
	vzeroupper
	call	_ZdlPvm@PLT
.L108:
	movq	%r14, %rdi
	call	_ZdaPv@PLT
.L95:
	testq	%rbp, %rbp
	je	.L109
.L110:
	movq	24(%rsp), %rsi
	movq	%rbp, %rdi
	subq	%rbp, %rsi
	call	_ZdlPvm@PLT
.L109:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L158
	movq	%rbx, %rdi
.LEHB16:
	call	_Unwind_Resume@PLT
.L157:
	call	__stack_chk_fail@PLT
.L116:
	endbr64
	movq	%rax, %rbx
	vzeroupper
	jmp	.L110
.L158:
	call	__stack_chk_fail@PLT
.L152:
	call	__stack_chk_fail@PLT
.L138:
	movq	168(%rsp), %rax
	subq	%fs:40, %rax
	jne	.L159
	leaq	.LC12(%rip), %rdi
	call	_ZSt19__throw_logic_errorPKc@PLT
.LEHE16:
.L159:
	call	__stack_chk_fail@PLT
.L155:
	vzeroupper
	jmp	.L88
.L156:
	call	__stack_chk_fail@PLT
.L146:
	vzeroupper
	jmp	.L108
	.cfi_endproc
.LFE6461:
	.section	.gcc_except_table
.LLSDAC6461:
	.byte	0xff
	.byte	0xff
	.byte	0x1
	.uleb128 .LLSDACSEC6461-.LLSDACSBC6461
.LLSDACSBC6461:
	.uleb128 .LEHB13-.LCOLDB15
	.uleb128 .LEHE13-.LEHB13
	.uleb128 .L115-.LCOLDB15
	.uleb128 0
	.uleb128 .LEHB14-.LCOLDB15
	.uleb128 .LEHE14-.LEHB14
	.uleb128 0
	.uleb128 0
	.uleb128 .LEHB15-.LCOLDB15
	.uleb128 .LEHE15-.LEHB15
	.uleb128 .L116-.LCOLDB15
	.uleb128 0
	.uleb128 .LEHB16-.LCOLDB15
	.uleb128 .LEHE16-.LEHB16
	.uleb128 0
	.uleb128 0
.LLSDACSEC6461:
	.section	.text.unlikely
	.section	.text.startup
	.size	main, .-main
	.section	.text.unlikely
	.size	main.cold, .-main.cold
.LCOLDE15:
	.section	.text.startup
.LHOTE15:
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
